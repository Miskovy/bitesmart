import math
from typing import Optional

from fastapi import FastAPI , Depends , HTTPException , APIRouter , Query , status

from app.models.food_model import FoodItem
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.food_schema import PaginatedFoodResponse , FoodItemResponse , FoodItemCreate , FoodItemUpdate

router = APIRouter()

@router.get("/",response_model=PaginatedFoodResponse ,tags=["Food"])
async def food(
        page: int = Query(1, ge=1, description="Page number"),
        limit: int = Query(10, ge=1, le=100, description="Items per page"),
        search: Optional[str] = Query(None, description="Search by food name"),
        db: Session = Depends(get_db)
):
    base_query = db.query(FoodItem)

    if search:
        # The % symbols act as wildcards: it finds the search string anywhere in the class_name
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
        data=food_chunk
    )


@router.get("/{food_id}", response_model=FoodItemResponse, tags=["Food"])
async def get_food_by_id(
        food_id: int,
        db: Session = Depends(get_db)
):
    food_item = db.query(FoodItem).filter(FoodItem.id == food_id).first()
    if not food_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Food item with ID {food_id} not found."
        )

    return food_item


@router.post("/", response_model=FoodItemResponse, status_code=status.HTTP_201_CREATED, tags=["Food"])
async def create_food(
        food_in: FoodItemCreate,
        db: Session = Depends(get_db)
):
    existing_food = db.query(FoodItem).filter(FoodItem.class_name == food_in.class_name).first()
    if existing_food:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Food item with class name '{food_in.class_name}' already exists."
        )

    new_food = FoodItem(**food_in.model_dump())
    db.add(new_food)
    db.commit()
    db.refresh(new_food)

    return new_food


@router.put("/{food_id}", response_model=FoodItemResponse, tags=["Food"])
async def update_food(
        food_id: int,
        food_in: FoodItemUpdate,
        db: Session = Depends(get_db)
):

    food_item = db.query(FoodItem).filter(FoodItem.id == food_id).first()
    if not food_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Food item with ID {food_id} not found."
        )

    # Extract only the fields that were actually provided in the request
    update_data = food_in.model_dump(exclude_unset=True)

    for key, value in update_data.items():
        setattr(food_item, key, value)

    db.commit()
    db.refresh(food_item)

    return food_item


@router.delete("/{food_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Food"])
async def delete_food(
        food_id: int,
        db: Session = Depends(get_db)
):

    food_item = db.query(FoodItem).filter(FoodItem.id == food_id).first()
    if not food_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Food item with ID {food_id} not found."
        )

    db.delete(food_item)
    db.commit()

    return None