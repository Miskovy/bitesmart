from fastapi import FastAPI , Request
from contextlib import asynccontextmanager
import traceback
from starlette.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException
from fastapi.exceptions import RequestValidationError

from app.config.config import settings
from app.utils.model_utils import load_model, load_class_names, load_onnx_model
from app.routers.prediction.v3.prediction import router as prediction_router
from app.middlewares.auth import InternalAuthMiddleware
from app.routers.prediction.v4.prediction import router as prediction_v4_router
from app.routers.food.food import router as food_router
# Loading Class names on start up
@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Server starting up..")

    app.state.class_names = load_class_names(settings.CLASS_LIST_PATH)
    app.state.convnext_session = load_onnx_model(settings.MODEL_PATH)
    app.state.yolo_session = load_onnx_model(settings.YOLO_MODEL_PATH)
    print("Server started..")
    yield
    print("Server shutting down..")

app = FastAPI(
    title="Bitesmart Ai",
    description="Bitesmart Ai",
    version="1.0.0",
    lifespan=lifespan
)

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "code": exc.status_code,
                "message": exc.detail,
            }
        }
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = [
        {
            "field": " → ".join(str(l) for l in err["loc"]),
            "message": err["msg"]
        }
        for err in exc.errors()
    ]
    return JSONResponse(
        status_code=422,
        content={
            "success": False,
            "error": {
                "code": 422,
                "message": "Validation failed",
                "details": errors
            }
        }
    )

@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    # Only print traceback in development
    if settings.DEBUG:
        traceback.print_exc()

    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error": {
                "code": 500,
                "message": "Internal server error" if not settings.DEBUG
                           else str(exc),
            }
        }
    )

app.add_middleware(InternalAuthMiddleware)

app.include_router(
    prediction_router,
    prefix="/api/v3",
    tags=["Prediction"]
)

app.include_router(
    prediction_v4_router,
    prefix="/api/v4",
    tags=["Prediction V4 (ONNX + Volume)"]
)

app.include_router(
    food_router,
    prefix="/api/food",
    tags=["Food"]
)

#Root
@app.get("/")
async def root():
    return {"message": "Welcome to Bitesmart Ai"}

@app.get("/health")
async def health():
    return {"status": "ok","model_loaded": hasattr(app.state, "model")}