from pydantic import BaseModel
from typing import List

class PredictionItem(BaseModel):
    class_name: str
    confidence: float
    class Config:
        json_encoders = {float: lambda v: float(f"{v:.4f}")}

class PredictionResponse(BaseModel):
    top5_predictions: List[PredictionItem]
    image_was_converted: bool