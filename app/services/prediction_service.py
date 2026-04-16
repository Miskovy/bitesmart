import uuid
from typing import List, Optional

import torch
from sqlalchemy.orm import Session

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.exceptions.ValidationException import ValidationException
from app.models.food_model import AiTrainingData, FoodItem
from app.schemas.prediction import PredictionItem, PredictionResponse
from app.schemas.prediction_v4 import (
    ArMeasurements,
    ArPredictionData,
    FallbackMeasurements,
    FallbackPredictionData,
    PredictionMacros,
)
from app.utils.image_utils import transform_image, validate_and_prepare_image
from app.utils.model_utils import process_image
from app.utils.yolo_utils import extract_food_mask, get_plate_diameter_cv2


# ── Helpers ───────────────────────────────────────────────────────────────────

def _save_training_data(
    db: Session,
    predicted_class: str,
    user_id: Optional[str] = None,
) -> str:
    """Save the AI prediction for the RLHF correction loop. Returns the record ID."""
    record = AiTrainingData(
        id=str(uuid.uuid4()),
        userId=user_id,
        originalPrediction=predicted_class,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return record.id


# ── V3: Top-5 Classification ─────────────────────────────────────────────────

async def predict_top5(
    file,
    model,
    device,
    class_names: List[str],
) -> PredictionResponse:
    image_bytes, was_converted = await validate_and_prepare_image(file)

    try:
        img_tensor = transform_image(image_bytes)
        img_tensor = img_tensor.to(device)
    except ValueError as e:
        raise AppException(ErrorCodes.BAD_REQUEST, str(e)) from e

    with torch.no_grad():
        outputs = model(img_tensor)
        probabilities = torch.nn.functional.softmax(outputs[0], dim=0)

    top5_prob, top5_idx = torch.topk(probabilities, 5)
    predictions = []

    for i in range(top5_prob.size(0)):
        confidence = top5_prob[i].item()
        class_name = class_names[top5_idx[i].item()]
        predictions.append(PredictionItem(class_name=class_name, confidence=confidence))

    return PredictionResponse(
        top5_predictions=predictions,
        image_was_converted=was_converted,
    )


# ── V4: Fallback (plate diameter) ────────────────────────────────────────────

def predict_food_volume_fallback(
    image_bytes: bytes,
    plate_diameter_cm: float,
    convnext_session,
    class_names,
    yolo_model,
    db: Session,
    user_id: Optional[str] = None,
) -> FallbackPredictionData:
    predicted_class = process_image(image_bytes, convnext_session, class_names)
    food_pixel_area, _ = extract_food_mask(image_bytes, yolo_model)
    plate_major_px, plate_minor_px = get_plate_diameter_cv2(image_bytes)

    if food_pixel_area == 0:
        raise ValidationException("Food detection", "Could not detect any food in the image.")
    if plate_major_px == 0 or plate_minor_px == 0:
        raise ValidationException("Plate detection", "Could not detect a circular plate. Please ensure the plate is fully visible.")

    food_record = db.query(FoodItem).filter(FoodItem.class_name == predicted_class).first()
    if not food_record:
        raise AppException(ErrorCodes.INTERNAL_ERROR, f"Class {predicted_class} missing from database.")

    perspective_factor = plate_major_px / plate_minor_px
    corrected_pixel_area = food_pixel_area * perspective_factor
    ratio = plate_diameter_cm / plate_major_px
    area_cm2 = corrected_pixel_area * (ratio ** 2)

    volume_cm3 = area_cm2 * food_record.avg_height_cm
    weight_g = volume_cm3 * food_record.density_g_cm3
    multiplier = weight_g / 100.0

    # Save prediction for RLHF
    training_id = _save_training_data(db, predicted_class, user_id)

    return FallbackPredictionData(
        food_detected=predicted_class,
        measurements=FallbackMeasurements(
            plate_diameter_cm=plate_diameter_cm,
            estimated_weight_g=round(weight_g, 2),
            estimated_volume_cm3=round(volume_cm3, 2),
        ),
        macros=PredictionMacros(
            calories=round(food_record.cals_per_100g * multiplier, 2),
            protein_g=round(food_record.protein_per_100g * multiplier, 2),
            carbs_g=round(food_record.carbs_per_100g * multiplier, 2),
            fats_g=round(food_record.fats_per_100g * multiplier, 2),
        ),
        training_data_id=training_id,
    )


# ── V4: AR (real-world width from mobile AR) ─────────────────────────────────

def predict_food_volume_ar(
    image_bytes: bytes,
    food_width_cm: float,
    convnext_session,
    class_names,
    yolo_model,
    db: Session,
    user_id: Optional[str] = None,
) -> ArPredictionData:
    predicted_class = process_image(image_bytes, convnext_session, class_names)
    pixel_area, pixel_width = extract_food_mask(image_bytes, yolo_model)

    if pixel_area == 0:
        raise ValidationException("Food detection", "Could not detect any food. Please try another angle.")

    food_record = db.query(FoodItem).filter(FoodItem.class_name == predicted_class).first()
    if not food_record:
        raise AppException(ErrorCodes.INTERNAL_ERROR, f"Class {predicted_class} missing from database.")

    ratio = food_width_cm / pixel_width
    real_area_cm2 = pixel_area * (ratio ** 2)

    volume_cm3 = real_area_cm2 * food_record.avg_height_cm
    weight_g = volume_cm3 * food_record.density_g_cm3
    multiplier = weight_g / 100.0

    # Save prediction for RLHF
    training_id = _save_training_data(db, predicted_class, user_id)

    return ArPredictionData(
        food_detected=predicted_class,
        measurements=ArMeasurements(
            ar_width_cm=food_width_cm,
            estimated_weight_g=round(weight_g, 2),
            estimated_volume_cm3=round(volume_cm3, 2),
        ),
        macros=PredictionMacros(
            calories=round(food_record.cals_per_100g * multiplier, 2),
            protein_g=round(food_record.protein_per_100g * multiplier, 2),
            carbs_g=round(food_record.carbs_per_100g * multiplier, 2),
            fats_g=round(food_record.fats_per_100g * multiplier, 2),
        ),
        training_data_id=training_id,
    )
