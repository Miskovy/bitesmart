from pydantic import BaseModel

class FoodItemBase(BaseModel):
    class_name: str
    avg_height_cm: float
    density_g_cm3: float
    protein_per_100g: float
    carbs_per_100g: float
    fats_per_100g: float
    cals_per_100g: float

class FoodItemCreate(FoodItemBase):
    pass

class FoodItemResponse(FoodItemBase):
    id: int

    class Config:
        from_attributes = True