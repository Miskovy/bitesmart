from fastapi import APIRouter, Depends, File, UploadFile, Form, HTTPException, Request
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.food_model import FoodItem
from app.utils.yolo_utils import extract_food_mask , get_plate_diameter_cv2
from app.utils.model_utils import process_image

router = APIRouter()


@router.post("/predict", tags=["Prediction Fallback"])
async def predict_food_volume_fallback(
        request: Request,
        file: UploadFile = File(..., description="The food image to analyze."),
        plate_diameter_cm: float = Form(..., description="Real-world diameter of the plate in cm."),
        db: Session = Depends(get_db)
):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image.")

    image_bytes = await file.read()

    convnext_session = request.app.state.convnext_session
    class_names = request.app.state.class_names
    yolo_model = request.app.state.yolo_ar_model

    predicted_class = process_image(image_bytes, convnext_session, class_names)
    food_pixel_area, _ = extract_food_mask(image_bytes, yolo_model)
    plate_pixel_diameter = get_plate_diameter_cv2(image_bytes)

    # Grab both measurements from the updated OpenCV function
    plate_major_px, plate_minor_px = get_plate_diameter_cv2(image_bytes)

    if food_pixel_area == 0:
        raise HTTPException(status_code=422, detail="Could not detect any food in the image.")
    if plate_pixel_diameter == 0:
        raise HTTPException(status_code=422, detail="Could not detect a circular plate. Please ensure the plate is fully visible.")

    food_record = db.query(FoodItem).filter(FoodItem.class_name == predicted_class).first()
    if not food_record:
        raise HTTPException(status_code=500, detail=f"Class {predicted_class} missing from database.")

    # Calculate how badly the camera is tilted (e.g., 2.5x squished)
    perspective_factor = plate_major_px / plate_minor_px

    # "Un-squish" the YOLO pixel count
    corrected_pixel_area = food_pixel_area * perspective_factor

    # Calculate the cm-per-pixel ratio using the unsquished horizontal width
    ratio = plate_diameter_cm / plate_major_px

    # Calculate real area using the corrected pixel count
    area_cm2 = corrected_pixel_area * (ratio ** 2)

    volume_cm3 = area_cm2 * food_record.avg_height_cm
    weight_g = volume_cm3 * food_record.density_g_cm3
    multiplier = weight_g / 100.0

    return {
        "success": True,
        "food_detected": predicted_class,
        "measurements": {
            "plate_diameter_cm": plate_diameter_cm,
            "estimated_weight_g": round(weight_g, 2),
            "estimated_volume_cm3": round(volume_cm3, 2)
        },
        "macros": {
            "calories": round(food_record.cals_per_100g * multiplier, 2),
            "protein_g": round(food_record.protein_per_100g * multiplier, 2),
            "carbs_g": round(food_record.carbs_per_100g * multiplier, 2),
            "fats_g": round(food_record.fats_per_100g * multiplier, 2)
        }
    }

@router.post("/predictAR", tags=["Prediction with AR"])
async def predict_food_volume_ar(
        request: Request,
        file: UploadFile = File(...),
        food_width_cm: float = Form(..., description="Real-world width of the food from Mobile AR"),
        db: Session = Depends(get_db)
):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image.")

    image_bytes = await file.read()

    # 1. Extract the specific AR model
    convnext_session = request.app.state.convnext_session
    class_names = request.app.state.class_names
    yolo_model = request.app.state.yolo_ar_model

    # 2. Use the 1-class utility
    predicted_class = process_image(image_bytes, convnext_session, class_names)
    pixel_area, pixel_width = extract_food_mask(image_bytes, yolo_model)

    if pixel_area == 0:
        raise HTTPException(status_code=422, detail="Could not detect any food. Please try another angle.")

    # 3. Database & Math
    food_record = db.query(FoodItem).filter(FoodItem.class_name == predicted_class).first()
    if not food_record:
        raise HTTPException(status_code=500, detail=f"Class {predicted_class} missing from database.")

    ratio = food_width_cm / pixel_width
    real_area_cm2 = pixel_area * (ratio ** 2)

    volume_cm3 = real_area_cm2 * food_record.avg_height_cm
    weight_g = volume_cm3 * food_record.density_g_cm3
    multiplier = weight_g / 100.0

    return {
        "success": True,
        "food_detected": predicted_class,
        "measurements": {
            "ar_width_cm": food_width_cm,
            "estimated_weight_g": round(weight_g, 2),
            "estimated_volume_cm3": round(volume_cm3, 2)
        },
        "macros": {
            "calories": round(food_record.cals_per_100g * multiplier, 2),
            "protein_g": round(food_record.protein_per_100g * multiplier, 2),
            "carbs_g": round(food_record.carbs_per_100g * multiplier, 2),
            "fats_g": round(food_record.fats_per_100g * multiplier, 2)
        }
    }