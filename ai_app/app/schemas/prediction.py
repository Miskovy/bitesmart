from typing import List

from pydantic import BaseModel, field_serializer


class PredictionItem(BaseModel):
    class_name: str
    confidence: float

    @field_serializer("confidence")
    def serialize_confidence(self, value: float) -> float:
        return float(f"{value:.4f}")


class PredictionResponse(BaseModel):
    top5_predictions: List[PredictionItem]
    image_was_converted: bool
