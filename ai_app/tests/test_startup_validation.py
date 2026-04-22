from pathlib import Path
from types import SimpleNamespace

import pytest

from app.services.startup_validation import validate_loaded_assets, validate_runtime_settings


def make_settings(tmp_path: Path, **overrides):
    model_path = tmp_path / "model.onnx"
    class_list_path = tmp_path / "classes.txt"
    yolo_ar_model_path = tmp_path / "yolo_ar.onnx"

    model_path.write_text("model", encoding="utf-8")
    class_list_path.write_text("salad\npizza\n", encoding="utf-8")
    yolo_ar_model_path.write_text("yolo", encoding="utf-8")

    values = {
        "INTERNAL_API_KEY": "key",
        "INTERNAL_API_SECRET": "secret",
        "MYSQL_USER": "root",
        "MYSQL_HOST": "localhost",
        "MYSQL_DB": "bitesmartDB",
        "GEMINI_API_KEY": "gemini-key",
        "MAX_IMAGE_UPLOAD_BYTES": 10 * 1024 * 1024,
        "HARD_MAX_IMAGE_UPLOAD_BYTES": 50 * 1024 * 1024,
        "MODEL_PATH": model_path,
        "CLASS_LIST_PATH": class_list_path,
        "YOLO_AR_MODEL_PATH": yolo_ar_model_path,
        "NUM_CLASSES": 2,
    }
    values.update(overrides)
    return SimpleNamespace(**values)


def test_validate_runtime_settings_accepts_valid_configuration(tmp_path):
    settings = make_settings(tmp_path)

    validate_runtime_settings(settings)


def test_validate_runtime_settings_rejects_missing_model_file(tmp_path):
    settings = make_settings(tmp_path, MODEL_PATH=tmp_path / "missing.onnx")

    with pytest.raises(FileNotFoundError, match="MODEL_PATH"):
        validate_runtime_settings(settings)


def test_validate_runtime_settings_rejects_empty_secrets(tmp_path):
    settings = make_settings(tmp_path, INTERNAL_API_SECRET="   ")

    with pytest.raises(ValueError, match="INTERNAL_API_SECRET"):
        validate_runtime_settings(settings)


def test_validate_loaded_assets_rejects_class_count_mismatch(tmp_path):
    settings = make_settings(tmp_path, NUM_CLASSES=3)

    with pytest.raises(ValueError, match="Class list count mismatch"):
        validate_loaded_assets(settings, ["salad", "pizza"])
