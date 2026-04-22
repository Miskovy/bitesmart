import logging
from io import BytesIO

import torch
from PIL import Image, UnidentifiedImageError
from timm.data.constants import IMAGENET_DEFAULT_MEAN, IMAGENET_DEFAULT_STD
from torchvision import transforms

from app.config.config import settings
from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.utils.upload_validation import read_validated_image_bytes


def transform_image(image_bytes: BytesIO) -> torch.Tensor:
    transform = transforms.Compose(
        [
            transforms.Resize((settings.IMG_SIZE + 32, settings.IMG_SIZE + 32)),
            transforms.CenterCrop(settings.IMG_SIZE),
            transforms.ToTensor(),
            transforms.Normalize(IMAGENET_DEFAULT_MEAN, IMAGENET_DEFAULT_STD),
        ]
    )
    try:
        img = Image.open(image_bytes).convert("RGB")
        img_tensor = transform(img)
        return img_tensor.unsqueeze(0)
    except Exception as e:
        logging.error(f"Error during image transformation: {e}")
        raise AppException(ErrorCodes.INTERNAL_ERROR, "Error transforming image.") from e


async def validate_and_prepare_image(file) -> tuple[BytesIO, bool]:
    contents = await read_validated_image_bytes(file)

    try:
        img = Image.open(BytesIO(contents))
    except UnidentifiedImageError as e:
        raise AppException(ErrorCodes.BAD_REQUEST, "Invalid image. Could not read image") from e

    file_format = img.format.upper()
    was_converted = False
    if file_format in ("PNG", "JPEG"):
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
