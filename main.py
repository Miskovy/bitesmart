from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from ultralytics import YOLO

from app.config.config import settings
from app.constants.SuccessCodes import SuccessCodes
from app.handlers.error_handler import (
    app_exception_handler,
    http_exception_handler,
    unhandled_exception_handler,
    validation_exception_handler,
)
from app.handlers.success_handler import success_response
from app.middlewares.auth import InternalAuthMiddleware
from app.exceptions.AppException import AppException
from app.routers.coach.coach import router as coachrouter
from app.routers.food.food import router as food_router
from app.routers.prediction.v3.prediction import router as prediction_router
from app.routers.prediction.v4.prediction import router as prediction_v4_router
from app.utils.model_utils import load_class_names, load_onnx_model


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Server starting up..")

    app.state.class_names = load_class_names(settings.CLASS_LIST_PATH)
    app.state.convnext_session = load_onnx_model(settings.MODEL_PATH)
    app.state.yolo_ar_model = YOLO(settings.YOLO_AR_MODEL_PATH, task="segment")

    print("Server started..")
    yield
    print("Server shutting down..")


app = FastAPI(
    title="Bitesmart Ai",
    description="Bitesmart Ai",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_exception_handler(AppException, app_exception_handler)
app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, unhandled_exception_handler)

app.add_middleware(InternalAuthMiddleware)

app.include_router(
    prediction_router,
    prefix="/api/v3",
    tags=["Prediction"],
)

app.include_router(
    prediction_v4_router,
    prefix="/api/v4",
    tags=["Prediction V4 (ONNX + Volume)"],
)

app.include_router(
    food_router,
    prefix="/api/food",
    tags=["Food"],
)

app.include_router(
    coachrouter,
    prefix="/api/coach",
    tags=["Coach"],
)


@app.get("/")
async def root():
    return success_response(
        SuccessCodes.OK,
        data={"message": "Welcome to Bitesmart Ai"},
        message="Root endpoint loaded successfully.",
    )


@app.get("/health")
async def health():
    return success_response(
        SuccessCodes.OK,
        data={"status": "ok", "model_loaded": hasattr(app.state, "convnext_session")},
        message="Health check completed successfully.",
    )
