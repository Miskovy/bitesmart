from typing import Optional

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.constants.SuccessCodes import SuccessCodes
from app.db.database import get_db
from app.handlers.success_handler import success_response
from app.schemas.food_schema import FoodItemCreate, FoodItemResponse, FoodItemUpdate, PaginatedFoodResponse
from app.schemas.success import SuccessResponse
from app.services import food_service

router = APIRouter()


@router.get("/", response_model=SuccessResponse[PaginatedFoodResponse], tags=["Food"])
async def food(
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(10, ge=1, le=100, description="Items per page"),
    search: Optional[str] = Query(None, description="Search by food name"),
    db: Session = Depends(get_db),
):
    result = food_service.list_foods(db=db, page=page, limit=limit, search=search)
    return success_response(
        SuccessCodes.OK,
        data=result.model_dump(),
        message="Food items loaded successfully.",
    )


@router.get("/{food_id}", response_model=SuccessResponse[FoodItemResponse], tags=["Food"])
async def get_food_by_id(
    food_id: int,
    db: Session = Depends(get_db),
):
    food_item = food_service.get_food_or_raise(db, food_id)
    payload = FoodItemResponse.model_validate(food_item)
    return success_response(
        SuccessCodes.OK,
        data=payload.model_dump(),
        message="Food item loaded successfully.",
    )


@router.post("/", response_model=SuccessResponse[FoodItemResponse], status_code=status.HTTP_201_CREATED, tags=["Food"])
async def create_food(
    food_in: FoodItemCreate,
    db: Session = Depends(get_db),
):
    new_food = food_service.create_food(db, food_in)
    payload = FoodItemResponse.model_validate(new_food)
    return success_response(
        SuccessCodes.CREATED,
        data=payload.model_dump(),
        message="Food item created successfully.",
    )


@router.put("/{food_id}", response_model=SuccessResponse[FoodItemResponse], tags=["Food"])
async def update_food(
    food_id: int,
    food_in: FoodItemUpdate,
    db: Session = Depends(get_db),
):
    updated_food = food_service.update_food(db, food_id, food_in)
    payload = FoodItemResponse.model_validate(updated_food)
    return success_response(
        SuccessCodes.OK,
        data=payload.model_dump(),
        message="Food item updated successfully.",
    )


@router.delete("/{food_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Food"])
async def delete_food(
    food_id: int,
    db: Session = Depends(get_db),
):
    food_service.delete_food(db, food_id)
    return success_response(SuccessCodes.NO_CONTENT)
