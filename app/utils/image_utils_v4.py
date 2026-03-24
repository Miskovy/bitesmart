import numpy as np
from PIL import Image, UnidentifiedImageError
from io import BytesIO
from fastapi import UploadFile, HTTPException, status
from app.config.config import settings
import logging

# Hardcode the ImageNet constants so we can remove the 'timm' dependency
IMAGENET_DEFAULT_MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
IMAGENET_DEFAULT_STD = np.array([0.229, 0.224, 0.225], dtype=np.float32)


def transform_image_onnx(image_bytes: BytesIO) -> np.ndarray:
    """
    Replicates the exact PyTorch V3 transforms:
    Resize(256, 256) -> CenterCrop(224) -> ToTensor() -> Normalize()
    """
    try:
        img = Image.open(image_bytes).convert("RGB")

        # 1. Resize to (IMG_SIZE + 32, IMG_SIZE + 32) -> usually (256, 256)
        target_size = settings.IMG_SIZE + 32
        img = img.resize((target_size, target_size), Image.Resampling.BILINEAR)

        # 2. CenterCrop to IMG_SIZE -> usually 224
        left = (target_size - settings.IMG_SIZE) / 2
        top = (target_size - settings.IMG_SIZE) / 2
        right = (target_size + settings.IMG_SIZE) / 2
        bottom = (target_size + settings.IMG_SIZE) / 2
        img = img.crop((left, top, right, bottom))

        # 3. ToTensor() equivalent: convert to float32 and scale to [0, 1]
        img_array = np.array(img, dtype=np.float32) / 255.0

        # 4. Normalize
        img_array = (img_array - IMAGENET_DEFAULT_MEAN) / IMAGENET_DEFAULT_STD

        # 5. Transpose from (H, W, C) to (C, H, W)
        img_array = np.transpose(img_array, (2, 0, 1))

        # 6. Add the batch dimension (1, C, H, W)
        img_array = np.expand_dims(img_array, axis=0)

        return img_array

    except Exception as e:
        logging.error(f"Error during ONNX image transformation: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error transforming image for ONNX."
        )


# Keep your original validation function exactly as it is!
async def validate_and_prepare_image(file: UploadFile) -> tuple[BytesIO, bool]:
    contents = await file.read()
    if not contents:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File is empty"
        )
    try:
        img = Image.open(BytesIO(contents))
    except UnidentifiedImageError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid image. Could not read image"
        )
    file_format = img.format.upper()
    was_converted = False
    if file_format in ("PNG", "JPEG", "JPG"):
        logging.info(f"Image is a {file_format}, no conversion needed.")
        return BytesIO(contents), was_converted

    logging.warning(f"Image is a {file_format}, Converting to JPEG")
    try:
        img_rgb = img.convert("RGB")
        output_bytes = BytesIO()
        img_rgb.save(output_bytes, format="JPEG")
        output_bytes.seek(0)
        was_converted = True
        return output_bytes, was_converted
    except Exception as e:
        logging.error(f"Error converting image to JPEG: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error converting image to JPEG: {e}"
        )