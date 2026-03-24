from sqlalchemy import Column, Integer, String, Float
from app.db.database import Base


class FoodItem(Base):
    __tablename__ = "food_items"

    id = Column(Integer, primary_key=True, index=True)
    class_name = Column(String(100), unique=True, index=True, nullable=False)

    # Volume calculation fields
    avg_height_cm = Column(Float, nullable=False, default=2.0)
    density_g_cm3 = Column(Float, nullable=False, default=1.0)

    # Nutritional fields (per 100g)
    protein_per_100g = Column(Float, nullable=False, default=0.0)
    carbs_per_100g = Column(Float, nullable=False, default=0.0)
    fats_per_100g = Column(Float, nullable=False, default=0.0)
    cals_per_100g = Column(Float, nullable=False, default=0.0)