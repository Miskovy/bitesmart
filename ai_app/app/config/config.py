from pathlib import Path

from pydantic_settings import BaseSettings

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent


class Settings(BaseSettings):
    # App
    PROJECT_NAME: str = "Bitesmart_Ai"
    DEBUG: bool = False
    APP_TIMEZONE: str = "UTC"
    PLATE_DEBUG_IMAGES: bool = False
    HEALTH_SNAPSHOT_INTERVAL_SECONDS: int = 30

    INTERNAL_API_KEY: str
    INTERNAL_API_SECRET: str
    ALLOWED_TIMESTAMP_DRIFT_SECONDS: int = 30

    MODEL_NAME: str = "convnext_base.fb_in22k"
    NUM_CLASSES: int = 119
    IMG_SIZE: int = 224

    MODEL_PATH: Path = PROJECT_ROOT / "storage" / "models" / "v4" / "convnext" /"convnext_base_119.onnx"
    CLASS_LIST_PATH: Path = PROJECT_ROOT / "storage" / "data" / "food_119_classes.txt"
    YOLO_MODEL_PATH: Path = PROJECT_ROOT / "storage" / "models" / "v4" / "segmentor" /"yolov8n-seg.onnx"
    YOLO_AR_MODEL_PATH: Path = PROJECT_ROOT / "storage" / "models" / "v4" / "segmentor" / "yolo_food_ar.onnx"

    MYSQL_USER: str = "root"
    MYSQL_PASSWORD: str
    MYSQL_HOST: str = "localhost"
    MYSQL_PORT: str = "3306"
    MYSQL_DB: str = "bitesmartDB"

    GEMINI_API_KEY: str

    class Config:
        env_file = str(PROJECT_ROOT / ".env")
        extra = 'ignore'

settings = Settings()
