from pydantic import BaseModel
from typing import List, Optional

class MacroInfo(BaseModel):
    protein_g: float
    carbs_g: float
    fats_g: float
    calories: float

class FoodAnalysisItem(BaseModel):
    class_name: str
    confidence: float
    estimated_weight_g: Optional[float] = None
    macros: Optional[MacroInfo] = None

class PredictionV4Response(BaseModel):
    success: bool = True
    plate_diameter_cm: float
    analysis: List[FoodAnalysisItem]