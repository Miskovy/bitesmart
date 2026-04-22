from typing import Optional

from pydantic import BaseModel, ConfigDict


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


class FoodItemUpdate(BaseModel):
    class_name: Optional[str] = None
    avg_height_cm: Optional[float] = None
    density_g_cm3: Optional[float] = None
    protein_per_100g: Optional[float] = None
    carbs_per_100g: Optional[float] = None
    fats_per_100g: Optional[float] = None
    cals_per_100g: Optional[float] = None


class FoodItemResponse(FoodItemBase):
    model_config = ConfigDict(from_attributes=True)

    id: int


class PaginatedFoodResponse(BaseModel):
    total_items: int
    total_pages: int
    current_page: int
    limit: int
    data: list[FoodItemResponse]
