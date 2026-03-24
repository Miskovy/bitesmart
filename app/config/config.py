from pydantic_settings import BaseSettings
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

class Settings(BaseSettings):
    # App
    PROJECT_NAME: str = "Bitesmart_Ai"
    DEBUG: bool = False

    # Internal service auth
    INTERNAL_API_KEY: str
    INTERNAL_API_SECRET: str
    ALLOWED_TIMESTAMP_DRIFT_SECONDS: int = 30

    # Model config (with defaults so .env doesn't need them)
    MODEL_NAME: str = "convnext_base.fb_in22k"
    NUM_CLASSES: int = 119
    IMG_SIZE: int = 224

    MODEL_PATH: Path = PROJECT_ROOT / "storage" / "models" / "v3" / "food_V3_convnext.pth"
    CLASS_LIST_PATH: Path = PROJECT_ROOT / "storage" / "data" / "food_119_classes.txt"

    MYSQL_USER: str = "root"
    MYSQL_PASSWORD: str
    MYSQL_HOST: str = "localhost"
    MYSQL_PORT: str = "3306"
    MYSQL_DB: str = "bitesmartDB"


    class Config:
        env_file = ".env"
        extra = 'ignore'

settings = Settings()