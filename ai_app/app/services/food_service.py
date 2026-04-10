import math
from typing import Optional

from sqlalchemy.orm import Session

from app.exceptions.ConflictException import ConflictException
from app.exceptions.NotFound import NotFoundException
from app.models.food_model import FoodItem
from app.schemas.food_schema import FoodItemCreate, FoodItemUpdate, PaginatedFoodResponse


def list_foods(
    db: Session,
    page: int,
    limit: int,
    search: Optional[str] = None,
) -> PaginatedFoodResponse:
    base_query = db.query(FoodItem)

    if search:
        base_query = base_query.filter(FoodItem.class_name.ilike(f"%{search}%"))

    total_items = base_query.count()
    skip = (page - 1) * limit
    total_pages = math.ceil(total_items / limit) if total_items > 0 else 0
    food_chunk = base_query.offset(skip).limit(limit).all()

    return PaginatedFoodResponse(
        total_items=total_items,
        total_pages=total_pages,
        current_page=page,
        limit=limit,
        data=food_chunk,
    )


def get_food_or_raise(db: Session, food_id: int) -> FoodItem:
    food_item = db.query(FoodItem).filter(FoodItem.id == food_id).first()
    if not food_item:
        raise NotFoundException("Food item", food_id)
    return food_item


def create_food(db: Session, food_in: FoodItemCreate) -> FoodItem:
    existing_food = db.query(FoodItem).filter(FoodItem.class_name == food_in.class_name).first()
    if existing_food:
        raise ConflictException(f"Food item with class name '{food_in.class_name}' already exists.")

    new_food = FoodItem(**food_in.model_dump())
    db.add(new_food)
    db.commit()
    db.refresh(new_food)
    return new_food


def update_food(db: Session, food_id: int, food_in: FoodItemUpdate) -> FoodItem:
    food_item = get_food_or_raise(db, food_id)
    update_data = food_in.model_dump(exclude_unset=True)

    for key, value in update_data.items():
        setattr(food_item, key, value)

    db.commit()
    db.refresh(food_item)
    return food_item


def delete_food(db: Session, food_id: int) -> None:
    food_item = get_food_or_raise(db, food_id)
    db.delete(food_item)
    db.commit()
