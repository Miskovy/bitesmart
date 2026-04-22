import logging
from io import BytesIO

import numpy as np
from PIL import Image, UnidentifiedImageError

from app.config.config import settings
from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.utils.upload_validation import read_validated_image_bytes

IMAGENET_DEFAULT_MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
IMAGENET_DEFAULT_STD = np.array([0.229, 0.224, 0.225], dtype=np.float32)


def transform_image_onnx(image_bytes: BytesIO) -> np.ndarray:
    try:
        img = Image.open(image_bytes).convert("RGB")
        target_size = settings.IMG_SIZE + 32
        img = img.resize((target_size, target_size), Image.Resampling.BILINEAR)

        left = (target_size - settings.IMG_SIZE) / 2
        top = (target_size - settings.IMG_SIZE) / 2
        right = (target_size + settings.IMG_SIZE) / 2
        bottom = (target_size + settings.IMG_SIZE) / 2
        img = img.crop((left, top, right, bottom))

        img_array = np.array(img, dtype=np.float32) / 255.0
        img_array = (img_array - IMAGENET_DEFAULT_MEAN) / IMAGENET_DEFAULT_STD
        img_array = np.transpose(img_array, (2, 0, 1))
        img_array = np.expand_dims(img_array, axis=0)
        return img_array
    except Exception as e:
        logging.error(f"Error during ONNX image transformation: {e}")
        raise AppException(ErrorCodes.INTERNAL_ERROR, "Error transforming image for ONNX.") from e


async def validate_and_prepare_image(file) -> tuple[BytesIO, bool]:
    contents = await read_validated_image_bytes(file)

    try:
        img = Image.open(BytesIO(contents))
    except UnidentifiedImageError as e:
        raise AppException(ErrorCodes.BAD_REQUEST, "Invalid image. Could not read image") from e

    file_format = img.format.upper()
    was_converted = False
    if file_format in ("PNG", "JPEG", "JPG"):
        logging.info(f"Image is a {file_format}, no conversion needed.")
        return BytesIO(contents), was_converted

    logging.warning(f"Image is a {file_format}, converting to JPEG")
    try:
        img_rgb = img.convert("RGB")
        output_bytes = BytesIO()
        img_rgb.save(output_bytes, format="JPEG")
        output_bytes.seek(0)
        was_converted = True
        return output_bytes, was_converted
    except Exception as e:
        logging.error(f"Error converting image to JPEG: {e}")
        raise AppException(ErrorCodes.INTERNAL_ERROR, f"Error converting image to JPEG: {e}") from e
