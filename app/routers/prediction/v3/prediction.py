from typing import List

from fastapi import APIRouter, Depends, File, UploadFile

from app.constants.SuccessCodes import SuccessCodes
from app.dependencies.dependencies import get_class_names, get_device, get_model
from app.handlers.success_handler import success_response
from app.schemas.prediction import PredictionResponse
from app.schemas.success import SuccessResponse
from app.services import prediction_service

router = APIRouter()


@router.post("/predict", response_model=SuccessResponse[PredictionResponse])
async def predict(
    file: UploadFile = File(..., description="The food image to classify."),
    model=Depends(get_model),
    device=Depends(get_device),
    class_names: List[str] = Depends(get_class_names),
):
    prediction = await prediction_service.predict_top5(
        file=file,
        model=model,
        device=device,
        class_names=class_names,
    )
    return success_response(
        SuccessCodes.OK,
        data=prediction.model_dump(),
        message="Prediction completed successfully.",
    )
