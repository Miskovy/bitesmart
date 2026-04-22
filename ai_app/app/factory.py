from contextlib import asynccontextmanager
import logging

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from ultralytics import YOLO

from sqlalchemy_utils import database_exists, create_database
from app.db.database import engine, Base

# Pre-import models so metadata knows about them
import app.models.user_model
import app.models.subscription_model
import app.models.food_model
import app.models.meal_plan_model
import app.models.gamification_model
import app.models.chat_model

from app.config.config import settings
from app.config.logging import configure_logging
from app.exceptions.AppException import AppException
from app.handlers.error_handler import (
    app_exception_handler,
    http_exception_handler,
    unhandled_exception_handler,
    validation_exception_handler,
)
from app.middlewares.auth import InternalAuthMiddleware
from app.middlewares.not_found import NotFoundHTMLMiddleware
from app.middlewares.request_logging import RequestLoggingMiddleware
from app.routers.coach.coach import router as coach_router
from app.routers.food.food import router as food_router
from app.routers.prediction.v3.prediction import router as prediction_router
from app.routers.prediction.v4.prediction import router as prediction_v4_router
from app.routers.system.system import router as system_router
from app.services.health_service import (
    initialize_health_state,
    mark_ready,
    mark_startup_failure,
    start_health_refresh_task,
    stop_health_refresh_task,
)
from app.services.startup_validation import validate_loaded_assets, validate_runtime_settings
from app.utils.model_utils import load_class_names, load_onnx_model

startup_logger = logging.getLogger("app.startup")


@asynccontextmanager
async def lifespan(app: FastAPI):
    startup_logger.info("startup_begin")
    initialize_health_state(app)
    start_health_refresh_task(app, settings.HEALTH_SNAPSHOT_INTERVAL_SECONDS)

    try:
        startup_logger.info("Verifying database connection and tables...")
        if not database_exists(engine.url):
            startup_logger.info(f"Database {engine.url.database} not found, creating it...")
            create_database(engine.url)
        Base.metadata.create_all(bind=engine)
        
        validate_runtime_settings(settings)

        app.state.class_names = load_class_names(settings.CLASS_LIST_PATH)
        validate_loaded_assets(settings, app.state.class_names)
        app.state.convnext_session = load_onnx_model(settings.MODEL_PATH)
        app.state.yolo_ar_model = YOLO(settings.YOLO_AR_MODEL_PATH, task="segment")
        mark_ready(app)

        startup_logger.info("startup_complete")
        yield
    except Exception as exc:
        mark_startup_failure(app, exc)
        startup_logger.exception("startup_failed error=%s", str(exc))
        raise
    finally:
        await stop_health_refresh_task(app)
        startup_logger.info("shutdown_complete")


def register_exception_handlers(app: FastAPI) -> None:
    app.add_exception_handler(AppException, app_exception_handler)
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(Exception, unhandled_exception_handler)


def register_middlewares(app: FastAPI) -> None:
    app.add_middleware(NotFoundHTMLMiddleware)
    app.add_middleware(InternalAuthMiddleware)
    app.add_middleware(RequestLoggingMiddleware)


def register_routers(app: FastAPI) -> None:
    app.include_router(system_router)
    # app.include_router(prediction_router, prefix="/api/v3", tags=["Prediction"])
    app.include_router(
        prediction_v4_router,
        prefix="/api/v4",
        tags=["Prediction V4 (ONNX + Volume)"],
    )
    app.include_router(food_router, prefix="/api/food", tags=["Food"])
    app.include_router(coach_router, prefix="/api/coach", tags=["Coach"])


def create_app() -> FastAPI:
    configure_logging()
    app = FastAPI(
        title="Bitesmart Ai",
        description="Bitesmart Ai",
        version="1.0.0",
        lifespan=lifespan,
    )

    register_exception_handlers(app)
    register_middlewares(app)
    register_routers(app)
    return app
