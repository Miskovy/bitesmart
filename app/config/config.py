from pydantic import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Bitesmart_Ai"

    class Config:
        env_file = ".env"

settings = Settings()