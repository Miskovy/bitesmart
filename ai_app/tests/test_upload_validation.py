from io import BytesIO

import pytest
from fastapi import UploadFile
from PIL import Image

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.utils import upload_validation


def build_image_bytes(size=(400, 400), image_format="PNG", color=(120, 180, 90)):
    image = Image.new("RGB", size, color=color)
    buffer = BytesIO()
    image.save(buffer, format=image_format)
    return buffer.getvalue()


@pytest.mark.anyio
async def test_read_validated_image_bytes_rejects_hard_limit(monkeypatch):
    monkeypatch.setattr(upload_validation.settings, "MAX_IMAGE_UPLOAD_BYTES", 10)
    monkeypatch.setattr(upload_validation.settings, "HARD_MAX_IMAGE_UPLOAD_BYTES", 20)

    file = UploadFile(
        filename="meal.jpg",
        file=BytesIO(b"x" * 21),
        headers={"content-type": "image/jpeg"},
    )

    with pytest.raises(AppException) as exc_info:
        await upload_validation.read_validated_image_bytes(file)

    assert exc_info.value.error_code == ErrorCodes.BAD_REQUEST.name
    assert "Maximum allowed size is 20 bytes before upload." in exc_info.value.message


@pytest.mark.anyio
async def test_read_validated_image_bytes_compresses_large_images(monkeypatch):
    monkeypatch.setattr(upload_validation.settings, "MAX_IMAGE_UPLOAD_BYTES", 6000)
    monkeypatch.setattr(upload_validation.settings, "HARD_MAX_IMAGE_UPLOAD_BYTES", 50000)
    monkeypatch.setattr(upload_validation.settings, "MAX_IMAGE_DIMENSION_PX", 512)

    original = build_image_bytes(size=(2500, 1800), image_format="PNG")
    assert len(original) > upload_validation.settings.MAX_IMAGE_UPLOAD_BYTES

    file = UploadFile(
        filename="meal.png",
        file=BytesIO(original),
        headers={"content-type": "image/png"},
    )

    processed = await upload_validation.read_validated_image_bytes(file)

    assert len(processed) <= upload_validation.settings.MAX_IMAGE_UPLOAD_BYTES
    image = Image.open(BytesIO(processed))
    assert max(image.size) <= upload_validation.settings.MAX_IMAGE_DIMENSION_PX


@pytest.mark.anyio
async def test_read_validated_image_bytes_rejects_unreadable_images(monkeypatch):
    monkeypatch.setattr(upload_validation.settings, "MAX_IMAGE_UPLOAD_BYTES", 10)
    monkeypatch.setattr(upload_validation.settings, "HARD_MAX_IMAGE_UPLOAD_BYTES", 50000)

    file = UploadFile(
        filename="meal.jpg",
        file=BytesIO(b"not-an-image-but-looks-large"),
        headers={"content-type": "image/jpeg"},
    )

    with pytest.raises(AppException) as exc_info:
        await upload_validation.read_validated_image_bytes(file)

    assert exc_info.value.error_code == ErrorCodes.BAD_REQUEST.name
    assert exc_info.value.message == "Invalid image. Could not read image"
