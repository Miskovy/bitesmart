import numpy as np
import time
from fastapi import APIRouter, Depends, File, UploadFile, Form, HTTPException, status

from sqlalchemy.orm import Session
from typing import List

from app.db.database import get_db
from app.models.food_model import FoodItem
from app.schemas.prediction_v4 import PredictionV4Response, FoodAnalysisItem, MacroInfo
from app.utils.image_utils_v4 import transform_image_onnx, validate_and_prepare_image
from app.dependencies.onnx_dependencies import get_convnext_session, get_yolo_session, get_class_names
from app.utils.math_helpers import calculate_softmax , get_top_k
router = APIRouter()


# --- 2. Mock Density Database ---
# You will eventually move this to a real database or a separate JSON file
FOOD_DATABASE = {
    "chicken_breast": {"height_cm": 2.5, "density": 1.06, "protein": 31, "carbs": 0, "fats": 3.6, "cals": 165},
    "white_rice": {"height_cm": 3.0, "density": 0.85, "protein": 2.7, "carbs": 28, "fats": 0.3, "cals": 130},
    # Add your 119 classes here...
}


@router.post("/predict", response_model=PredictionV4Response)
async def predict_v4(
        file: UploadFile = File(..., description="The food image to analyze."),
        plate_diameter_cm: float = Form(..., description="Real-world diameter of the plate in cm."),
        convnext_session=Depends(get_convnext_session),
        class_names: List[str] = Depends(get_class_names),
        db: Session = Depends(get_db)  # Inject the MySQL session
):
    # 1. Image Preparation
    image_bytes, was_converted = await validate_and_prepare_image(file)

    try:
        start_time = time.time()
        img_array = transform_image_onnx(image_bytes)

        # 2. ConvNeXt Inference
        input_name = convnext_session.get_inputs()[0].name
        outputs = convnext_session.run(None, {input_name: img_array})
        logits = outputs[0][0]

        # 3. Process Probabilities
        probabilities = calculate_softmax(logits)
        top5_prob, top5_idx = get_top_k(probabilities, 5)

        predicted_class = class_names[top5_idx[0]]
        confidence = float(top5_prob[0])

        # 4. Database Lookup
        # Fetch the real density, height, and macros from bitesmartDB
        food_db_item = db.query(FoodItem).filter(FoodItem.class_name == predicted_class).first()

        if not food_db_item:
            # Fallback if the class isn't in the DB for some reason
            height = 2.0
            density = 1.0
            macros_base = {"pro": 0, "carbs": 0, "fat": 0, "cals": 0}
        else:
            height = food_db_item.avg_height_cm
            density = food_db_item.density_g_cm3
            macros_base = {
                "pro": food_db_item.protein_per_100g,
                "carbs": food_db_item.carbs_per_100g,
                "fat": food_db_item.fats_per_100g,
                "cals": food_db_item.cals_per_100g
            }

        # --- 5. VOLUME ESTIMATION (Still using placeholders for YOLO) ---
        # Soon we will replace these with real YOLOv8-Seg mask outputs
        mock_food_pixel_area = 15000
        mock_plate_pixel_diameter = 800

        ratio = plate_diameter_cm / mock_plate_pixel_diameter
        area_cm2 = mock_food_pixel_area * (ratio ** 2)

        # Calculation: Area * Height * Density
        weight_grams = area_cm2 * height * density

        # 6. Calculate Real Macros based on Weight
        multiplier = weight_grams / 100.0
        final_macros = MacroInfo(
            protein_g=round(macros_base["pro"] * multiplier, 1),
            carbs_g=round(macros_base["carbs"] * multiplier, 1),
            fats_g=round(macros_base["fat"] * multiplier, 1),
            calories=round(macros_base["cals"] * multiplier, 1)
        )

        print(f"Full V4 Pipeline took: {time.time() - start_time:.3f}s")

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Inference or DB lookup failed: {str(e)}"
        )

    # 7. Final Response
    analysis_result = FoodAnalysisItem(
        class_name=predicted_class,
        confidence=confidence,
        estimated_weight_g=round(weight_grams, 1),
        macros=final_macros
    )

    return PredictionV4Response(
        success=True,
        plate_diameter_cm=plate_diameter_cm,
        analysis=[analysis_result]
    )