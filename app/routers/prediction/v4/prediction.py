from typing import Optional

from fastapi import APIRouter, Depends, File, Form, Request, UploadFile
from sqlalchemy.orm import Session

from app.constants.SuccessCodes import SuccessCodes
from app.db.database import get_db
from app.exceptions.NotFound import NotFoundException
from app.handlers.success_handler import success_response
from app.models.food_model import AiTrainingData
from app.schemas.prediction_v4 import ArPredictionData, FallbackPredictionData
from app.schemas.success import SuccessResponse
from app.services import prediction_service
from app.utils.upload_validation import read_validated_image_bytes

router = APIRouter()


# ── Prediction Endpoints ─────────────────────────────────────────────────────

@router.post("/predict", response_model=SuccessResponse[FallbackPredictionData], tags=["Prediction Fallback"])
async def predict_food_volume_fallback(
    request: Request,
    file: UploadFile = File(..., description="The food image to analyze."),
    plate_diameter_cm: float = Form(..., gt=0, description="Real-world diameter of the plate in cm."),
    user_id: Optional[str] = Form(None, description="User UUID (optional, enables RLHF tracking)."),
    db: Session = Depends(get_db),
):
    image_bytes = await read_validated_image_bytes(file)
    result = prediction_service.predict_food_volume_fallback(
        image_bytes=image_bytes,
        plate_diameter_cm=plate_diameter_cm,
        convnext_session=request.app.state.convnext_session,
        class_names=request.app.state.class_names,
        yolo_model=request.app.state.yolo_ar_model,
        db=db,
        user_id=user_id,
    )
    return success_response(
        SuccessCodes.OK,
        data=result.model_dump(),
        message="Food volume prediction completed successfully.",
    )


@router.post("/predictAR", response_model=SuccessResponse[ArPredictionData], tags=["Prediction with AR"])
async def predict_food_volume_ar(
    request: Request,
    file: UploadFile = File(...),
    food_width_cm: float = Form(..., gt=0, description="Real-world width of the food from Mobile AR"),
    user_id: Optional[str] = Form(None, description="User UUID (optional, enables RLHF tracking)."),
    db: Session = Depends(get_db),
):
    image_bytes = await read_validated_image_bytes(file)
    result = prediction_service.predict_food_volume_ar(
        image_bytes=image_bytes,
        food_width_cm=food_width_cm,
        convnext_session=request.app.state.convnext_session,
        class_names=request.app.state.class_names,
        yolo_model=request.app.state.yolo_ar_model,
        db=db,
        user_id=user_id,
    )
    return success_response(
        SuccessCodes.OK,
        data=result.model_dump(),
        message="AR food volume prediction completed successfully.",
    )


# ── RLHF Correction Endpoint ─────────────────────────────────────────────────

@router.put("/correct/{training_data_id}", tags=["AI Training"])
async def submit_correction(
    training_data_id: str,
    user_correction: str = Form(..., description="What the food actually was (e.g. 'Molokhia')."),
    db: Session = Depends(get_db),
):
    """
    Submit a user correction for an AI prediction.
    This feeds the RLHF loop — admin can review corrections to improve the model.
    """
    record = db.query(AiTrainingData).filter(AiTrainingData.id == training_data_id).first()
    if not record:
        raise NotFoundException("Training data record", training_data_id)

    record.userCorrection = user_correction
    db.commit()

    return success_response(
        SuccessCodes.OK,
        data={
            "training_data_id": record.id,
            "original_prediction": record.originalPrediction,
            "user_correction": record.userCorrection,
        },
        message="Correction submitted successfully. Thank you for improving Bitesmart!",
    )
