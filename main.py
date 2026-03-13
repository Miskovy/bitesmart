from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.config import settings
from app.schemas import prediction
from app.utils.model_utils import load_model , load_class_names
from app.routers.prediction.prediction import router as prediction_router

# Loading Class names on start up
@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Server starting up..")

    app.state.class_names = load_class_names(settings.CLASS_LIST_PATH)

    model, device = load_model(settings.MODEL_PATH, settings.NUM_CLASSES)
    app.state.model = model
    app.state.device = device
    print("Server started..")
    yield
    print("Server shutting down..")

app = FastAPI(
    title="Bitesmart Ai",
    description="Bitesmart Ai",
    version="1.0.0",
    lifespan=lifespan
)
app.include_router(
    prediction_router,
    prefix="/api/v3",
    tags=["Prediction"]
)
#Root
@app.get("/")
async def root():
    return {"message": "Welcome to Bitesmart Ai"}

@app.get("/health")
async def health():
    return {"status": "ok","model_loaded": hasattr(app.state, "model")}