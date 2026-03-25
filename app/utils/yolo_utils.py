import cv2
import numpy as np


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