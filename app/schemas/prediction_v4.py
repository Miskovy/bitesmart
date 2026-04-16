from typing import Optional

from pydantic import BaseModel


class PredictionMacros(BaseModel):
    calories: float
    protein_g: float
    carbs_g: float
    fats_g: float


class FallbackMeasurements(BaseModel):
    plate_diameter_cm: float
    estimated_weight_g: float
    estimated_volume_cm3: float


class ArMeasurements(BaseModel):
    ar_width_cm: float
    estimated_weight_g: float
    estimated_volume_cm3: float


class FallbackPredictionData(BaseModel):
    food_detected: str
    measurements: FallbackMeasurements
    macros: PredictionMacros
    training_data_id: Optional[str] = None


class ArPredictionData(BaseModel):
    food_detected: str
    measurements: ArMeasurements
    macros: PredictionMacros
    training_data_id: Optional[str] = None

