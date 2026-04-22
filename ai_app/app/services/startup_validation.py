from pathlib import Path


def _require_non_empty(name: str, value: str) -> None:
    if not value or not value.strip():
        raise ValueError(f"{name} must not be empty.")


def _require_file(name: str, path: Path) -> None:
    if not path.exists():
        raise FileNotFoundError(f"{name} file not found: {path}")
    if not path.is_file():
        raise ValueError(f"{name} path is not a file: {path}")


def validate_runtime_settings(settings) -> None:
    if settings.HARD_MAX_IMAGE_UPLOAD_BYTES < settings.MAX_IMAGE_UPLOAD_BYTES:
        raise ValueError("HARD_MAX_IMAGE_UPLOAD_BYTES must be greater than or equal to MAX_IMAGE_UPLOAD_BYTES.")

    _require_non_empty("INTERNAL_API_KEY", settings.INTERNAL_API_KEY)
    _require_non_empty("INTERNAL_API_SECRET", settings.INTERNAL_API_SECRET)
    _require_non_empty("MYSQL_USER", settings.MYSQL_USER)
    _require_non_empty("MYSQL_HOST", settings.MYSQL_HOST)
    _require_non_empty("MYSQL_DB", settings.MYSQL_DB)
    _require_non_empty("GEMINI_API_KEY", settings.GEMINI_API_KEY)

    _require_file("MODEL_PATH", settings.MODEL_PATH)
    _require_file("CLASS_LIST_PATH", settings.CLASS_LIST_PATH)
    _require_file("YOLO_AR_MODEL_PATH", settings.YOLO_AR_MODEL_PATH)


def validate_loaded_assets(settings, class_names: list[str]) -> None:
    expected_classes = settings.NUM_CLASSES
    actual_classes = len(class_names)
    if actual_classes != expected_classes:
        raise ValueError(
            f"Class list count mismatch: expected {expected_classes}, got {actual_classes}."
        )
