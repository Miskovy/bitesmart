from fastapi import UploadFile
from io import BytesIO

from PIL import Image, UnidentifiedImageError

from app.config.config import settings
from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException


def _format_size_limit(num_bytes: int) -> str:
    size_mb = num_bytes / (1024 * 1024)
    if size_mb >= 1:
        return f"{size_mb:.0f} MB"
    size_kb = num_bytes / 1024
    if size_kb >= 1:
        return f"{size_kb:.0f} KB"
    return f"{num_bytes} bytes"


def validate_image_content_type(file: UploadFile) -> None:
    if not file.content_type or not file.content_type.startswith("image/"):
        raise AppException(ErrorCodes.BAD_REQUEST, "File provided is not an image.")


def _compress_image_to_budget(contents: bytes) -> bytes:
    try:
        image = Image.open(BytesIO(contents))
    except UnidentifiedImageError as exc:
        raise AppException(ErrorCodes.BAD_REQUEST, "Invalid image. Could not read image") from exc

    image.load()
    image = image.convert("RGB")

    max_dimension = settings.MAX_IMAGE_DIMENSION_PX
    if max(image.size) > max_dimension:
        image.thumbnail((max_dimension, max_dimension), Image.Resampling.LANCZOS)

    quality_steps = (85, 75, 65, 55)
    for quality in quality_steps:
        buffer = BytesIO()
        image.save(buffer, format="JPEG", quality=quality, optimize=True)
        compressed = buffer.getvalue()
        if len(compressed) <= settings.MAX_IMAGE_UPLOAD_BYTES:
            return compressed

    return compressed


async def read_validated_image_bytes(file: UploadFile) -> bytes:
    validate_image_content_type(file)

    contents = await file.read()
    if not contents:
        raise AppException(ErrorCodes.BAD_REQUEST, "File is empty")

    if len(contents) > settings.HARD_MAX_IMAGE_UPLOAD_BYTES:
        raise AppException(
            ErrorCodes.BAD_REQUEST,
            f"Image file is too large. Maximum allowed size is {_format_size_limit(settings.HARD_MAX_IMAGE_UPLOAD_BYTES)} before upload.",
        )

    if len(contents) > settings.MAX_IMAGE_UPLOAD_BYTES:
        contents = _compress_image_to_budget(contents)
        if len(contents) > settings.MAX_IMAGE_UPLOAD_BYTES:
            raise AppException(
                ErrorCodes.BAD_REQUEST,
                f"Image file is too large to process. Compress it before upload to {_format_size_limit(settings.MAX_IMAGE_UPLOAD_BYTES)} or less.",
            )

    return contents
