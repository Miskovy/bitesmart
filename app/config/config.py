from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(PROJECT_ROOT / ".env"),
        extra="ignore",
    )

    # App
    PROJECT_NAME: str = "Bitesmart_Ai"
    DEBUG: bool = False
    APP_TIMEZONE: str = "UTC"
    PLATE_DEBUG_IMAGES: bool = False
    HEALTH_SNAPSHOT_INTERVAL_SECONDS: int = Field(default=30, gt=0)
    MAX_IMAGE_UPLOAD_BYTES: int = Field(default=10 * 1024 * 1024, gt=0)
    HARD_MAX_IMAGE_UPLOAD_BYTES: int = Field(default=50 * 1024 * 1024, gt=0)
    MAX_IMAGE_DIMENSION_PX: int = Field(default=2048, gt=0)
    DB_POOL_SIZE: int = Field(default=5, gt=0)
    DB_MAX_OVERFLOW: int = Field(default=10, ge=0)
    DB_POOL_TIMEOUT_SECONDS: int = Field(default=30, gt=0)
    DB_POOL_RECYCLE_SECONDS: int = Field(default=1800, gt=0)

    INTERNAL_API_KEY: str
    INTERNAL_API_SECRET: str
    ALLOWED_TIMESTAMP_DRIFT_SECONDS: int = Field(default=30, gt=0)

    MODEL_NAME: str = "convnext_base.fb_in22k"
    NUM_CLASSES: int = Field(default=119, gt=0)
    IMG_SIZE: int = Field(default=224, gt=0)

    MODEL_PATH: Path = PROJECT_ROOT / "storage" / "models" / "v4" / "convnext" /"convnext_base_119.onnx"
    CLASS_LIST_PATH: Path = PROJECT_ROOT / "storage" / "data" / "food_119_classes.txt"
    YOLO_MODEL_PATH: Path = PROJECT_ROOT / "storage" / "models" / "v4" / "segmentor" /"yolov8n-seg.onnx"
    YOLO_AR_MODEL_PATH: Path = PROJECT_ROOT / "storage" / "models" / "v4" / "segmentor" / "yolo_food_ar.onnx"

    MYSQL_USER: str = "root"
    MYSQL_PASSWORD: str
    MYSQL_HOST: str = "localhost"
    MYSQL_PORT: int = Field(default=3306, gt=0)
    MYSQL_DB: str = "bitesmartDB"

    GEMINI_API_KEY: str

settings = Settings()
