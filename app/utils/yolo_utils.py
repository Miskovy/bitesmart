from datetime import datetime

import cv2
import numpy as np
import io
from PIL import Image
from ultralytics import YOLO
import os

def sigmoid(x: np.ndarray) -> np.ndarray:
    """Applies the sigmoid function to convert raw mask logits into probabilities [0, 1]."""
    return 1 / (1 + np.exp(-x))


def process_yolo_onnx(image_bytes: bytes, yolo_session) -> tuple[float, float]:
    """
    Runs YOLOv8-Seg ONNX inference and decodes the matrices.
    Returns: (food_pixel_area, plate_pixel_diameter)
    """
    # 1. Read and Resize (Direct resize unwarps perfectly later)
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    orig_h, orig_w = img.shape[:2]

    # YOLOv8 standard input
    input_img = cv2.resize(img, (640, 640))
    input_img = cv2.cvtColor(input_img, cv2.COLOR_BGR2RGB)
    input_img = input_img.astype(np.float32) / 255.0
    input_img = np.transpose(input_img, (2, 0, 1))
    input_img = np.expand_dims(input_img, axis=0)

    # 2. Run ONNX Session
    input_name = yolo_session.get_inputs()[0].name
    outputs = yolo_session.run(None, {input_name: input_img})

    # 3. Parse Output Tensors
    # outputs[0]: Predictions (1, Total_Classes + 4 + 32, 8400)
    # outputs[1]: Prototype Masks (1, 32, 160, 160)
    preds = outputs[0][0].T  # Transpose to shape: (8400, length)
    protos = outputs[1][0]  # Shape: (32, 160, 160)

    # Dynamically calculate number of classes (Length - 4 bbox coords - 32 mask coeffs)
    num_classes = preds.shape[1] - 4 - 32

    # Split the predictions array
    boxes = preds[:, :4]  # xc, yc, w, h
    scores = np.max(preds[:, 4: 4 + num_classes], axis=1)
    mask_coeffs = preds[:, 4 + num_classes:]

    # Convert (xc, yc, w, h) to (x_min, y_min, width, height) for OpenCV NMS
    x = boxes[:, 0] - boxes[:, 2] / 2
    y = boxes[:, 1] - boxes[:, 3] / 2
    w = boxes[:, 2]
    h = boxes[:, 3]
    cv_boxes = np.column_stack((x, y, w, h)).tolist()

    # 4. Non-Maximum Suppression (Filter overlapping boxes)
    indices = cv2.dnn.NMSBoxes(cv_boxes, scores.tolist(), score_threshold=0.5, nms_threshold=0.4)

    food_pixel_area = 0.0
    plate_pixel_diameter = 0.0

    if len(indices) > 0:
        indices = indices.flatten()

        for i in indices:
            # A. Calculate Plate Diameter from the Bounding Box
            # Map the 640x640 bounding box back to the original image resolution
            scale_x = orig_w / 640.0
            scale_y = orig_h / 640.0

            real_bw = w[i] * scale_x
            real_bh = h[i] * scale_y

            # Assuming the largest detected object encapsulates the plate
            max_dim = max(real_bw, real_bh)
            if max_dim > plate_pixel_diameter:
                plate_pixel_diameter = max_dim

            # B. Calculate Food Area from the Mask
            coeff = mask_coeffs[i]

            # Matrix multiplication: Coefficients (32) x Flattened Protos (32, 25600)
            proto_flat = protos.reshape(32, -1)
            mask_flat = np.matmul(coeff, proto_flat)

            # Reshape back to 160x160 and apply sigmoid
            mask_2d = sigmoid(mask_flat).reshape(160, 160)

            # Resize mask to original image dimensions to unwarp it
            mask_resized = cv2.resize(mask_2d, (orig_w, orig_h), interpolation=cv2.INTER_LINEAR)

            # Threshold to create a binary mask (1 for food, 0 for background)
            binary_mask = mask_resized > 0.5

            # Count the pixels
            area = np.sum(binary_mask)
            if area > food_pixel_area:
                food_pixel_area = area

    # Fallback safety: If nothing is detected, assume the plate takes up 80% of the image width
    if plate_pixel_diameter == 0:
        plate_pixel_diameter = orig_w * 0.8

    return float(food_pixel_area), float(plate_pixel_diameter)


# def extract_food_mask(image_bytes: bytes, yolo_model: YOLO):
#     """
#     Passes the image to the 1-Class YOLO ONNX model.
#     Returns the pixel area of the mask and the pixel width of the bounding box.
#     """
#     # 1. Convert bytes to PIL Image
#     image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
#
#     # 2. Run inference. (Ultralytics natively routes .onnx files to the CPU)
#     # We set conf=0.25 to ignore low-confidence background noise
#     results = yolo_model.predict(image, imgsz=640, conf=0.25)
#
#     # 3. Extract the first result (since we only passed one image)
#     result = results[0]
#
#     # 4. Safety Check: Did it find any food at all?
#     if result.masks is None or len(result.masks.data) == 0:
#         return 0.0, 0.0
#
#         # 5. Extract Data
#     # Grab the 2D binary array of the first mask (0s for background, 1s for food)
#     mask_data = result.masks.data[0].cpu().numpy()
#
#     # The area is simply the sum of all the '1' pixels in the mask
#     pixel_area = np.sum(mask_data)
#
#     # Get the bounding box coordinates [x1, y1, x2, y2]
#     box = result.boxes.xyxy[0].cpu().numpy()
#
#     # Width = x2 - x1
#     pixel_width = box[2] - box[0]
#
#     return float(pixel_area), float(pixel_width)

def extract_food_mask(image_bytes: bytes, yolo_model: YOLO):
    # 1. Open the image and get its ORIGINAL massive dimensions
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    orig_width, orig_height = image.size

    # 2. YOLO internally shrinks it to 640x640 for AI inference
    results = yolo_model.predict(image, imgsz=640, conf=0.25)
    result = results[0]

    if result.masks is None or len(result.masks.data) == 0:
        return 0.0, 0.0

    total_pixel_area = 0.0

    # Add up all the masks (all 12 donuts)
    for mask in result.masks.data:
        mask_data = mask.cpu().numpy()
        total_pixel_area += float(np.sum(mask_data))

    # --- THE RESOLUTION SYNC FIX ---
    # Get the tiny dimensions of YOLO's internal mask tensor
    mask_h, mask_w = result.masks.data.shape[1], result.masks.data.shape[2]

    # Calculate how much YOLO shrunk the image's area
    area_scale_factor = (orig_width * orig_height) / (mask_w * mask_h)

    # Multiply the tiny pixel count by the scale factor to restore it to the original OpenCV resolution!
    true_total_pixel_area = total_pixel_area * area_scale_factor
    # -------------------------------

    # Note: YOLO automatically scales bounding boxes back to original coordinates, so this line is already safe!
    box = result.boxes.xyxy[0].cpu().numpy()
    pixel_width = box[2] - box[0]

    return float(true_total_pixel_area), float(pixel_width)


def extract_food_and_plate(image_bytes: bytes, yolo_model: YOLO):
    """
    Passes the image to the 2-Class YOLO ONNX model (Food + Plate).
    Assuming Class 0 is Food, and Class 1 is Plate.
    Returns the total food pixel area and the plate's pixel width.
    """
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    results = yolo_model.predict(image, imgsz=640, conf=0.25)
    result = results[0]

    food_pixel_area = 0.0
    plate_pixel_width = 0.0

    # Safety check: Did it find anything at all?
    if result.masks is None or result.boxes is None:
        return food_pixel_area, plate_pixel_width

    # Extract arrays
    masks_data = result.masks.data.cpu().numpy()
    boxes_data = result.boxes.cpu().numpy()

    # Loop through all detected objects
    for i, box in enumerate(boxes_data):
        class_id = int(box.cls[0])  # Get the class ID (0 or 1)

        if class_id == 0:  # 0 = Food
            # If there are multiple food items, add their areas together
            food_pixel_area += float(np.sum(masks_data[i]))

        elif class_id == 1:  # 1 = Plate
            # Width = x2 - x1
            width = box.xyxy[0][2] - box.xyxy[0][0]
            # If it finds multiple plates, keep the biggest one
            if width > plate_pixel_width:
                plate_pixel_width = float(width)

    return food_pixel_area, plate_pixel_width


def get_plate_diameter_cv2(image_bytes: bytes) -> tuple[float, float]:
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # 1. Force Contrast: Make the plate stand out from the tablecloth
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
    contrast_gray = clahe.apply(gray)

    # 2. Median Blur: Erases the fork/knife details while keeping the plate edge hard
    blurred = cv2.medianBlur(contrast_gray, 15)

    # 3. Aggressive Edge Detection: Catch faint shadows (lowered from 30/150 to 10/50)
    edges = cv2.Canny(blurred, 10, 50)

    # 4. Bridge the Gaps: Thicken the lines to skip over the fork and knife
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (15, 15))
    closed_edges = cv2.dilate(edges, kernel, iterations=3)

    # 5. Grab EVERYTHING (RETR_LIST instead of RETR_EXTERNAL)
    contours, _ = cv2.findContours(closed_edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

    # 6. Filter for massive objects (plates are huge, crumbs are small)
    valid_contours = [c for c in contours if len(c) >= 5 and cv2.contourArea(c) > 20000]

    if valid_contours:
        largest_contour = max(valid_contours, key=cv2.contourArea)
        ellipse = cv2.fitEllipse(largest_contour)

        # Safely grab the long side and short side
        (xc, yc), axes, angle = ellipse
        major_axis = max(axes)
        minor_axis = min(axes)

        # --- VISUAL DEBUGGING ---
        log_dir = os.path.join("storage", "logs")
        os.makedirs(log_dir, exist_ok=True)
        cv2.ellipse(img, ellipse, (0, 255, 0), 4)
        filepath = os.path.join(log_dir, f"plate_debug_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg")
        cv2.imwrite(filepath, img)
        print(f"Debug image saved to: {filepath}")
        # ------------------------

        # Return BOTH axes instead of just one
        return float(major_axis), float(minor_axis)

    return 0.0, 0.0