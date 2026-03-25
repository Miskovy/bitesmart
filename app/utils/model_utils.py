import torch
import timm
from pathlib import Path
from typing import List
from app.config.config import settings
import onnxruntime as ort
import numpy as np
from PIL import Image
import io

def load_class_names(class_list_path: Path) -> List[str]:
    if not class_list_path.exists():
        raise FileNotFoundError(f"Class list file not found: {class_list_path}")
    print(f"Loading class list from {class_list_path}")
    with open(class_list_path, "r") as f:
        class_names = [line.strip() for line in f.readlines()]

    print(f"Loaded {len(class_names)} class names.")

    return class_names


def load_onnx_model(model_path: Path) -> ort.InferenceSession:
    """
    Loads an ONNX model into memory using the CPU Execution Provider.
    """
    if not model_path.exists():
        raise FileNotFoundError(f"ONNX Model file not found: {model_path}")

    print(f"Loading ONNX model from {model_path}")

    # We explicitly declare the CPUExecutionProvider to avoid any warnings
    # about missing CUDA/GPU drivers on your production server.
    session = ort.InferenceSession(
        str(model_path),
        providers=['CPUExecutionProvider']
    )

    print(f"ONNX Model loaded successfully.")
    return session

def load_model(model_path: Path,num_classes: int):
    if not model_path.exists():
        raise FileNotFoundError(f"Model file not found: {model_path}")
    print(f"Loading model from {model_path}")

    model = timm.create_model(
        settings.MODEL_NAME,
        pretrained=False,
        num_classes=num_classes
    )
    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Using {device} device.")

    model.load_state_dict(
        torch.load(model_path, map_location=torch.device(device))
    )

    model.to(device)
    model.eval() #Setting the model to evaluation

    print(f"Model loaded from {model_path}")
    return model,device


def process_image(image_bytes: bytes, session: ort.InferenceSession, class_names: List[str]) -> str:
    """
    Takes raw image bytes, runs pure ONNX CPU inference, and returns the food class name.
    """
    # 1. Open image and convert to RGB
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")

    # 2. Resize to 224x224 (The standard input size for ConvNeXt)
    image = image.resize((224, 224))

    # 3. Convert to numpy array and normalize (Force float32 everywhere)
    img_data = np.array(image).astype(np.float32) / 255.0
    mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
    std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
    img_data = (img_data - mean) / std

    # 4. Transpose to Channel-First format: HWC (224,224,3) -> CHW (3,224,224)
    img_data = np.transpose(img_data, (2, 0, 1))

    # 5. Add Batch Dimension and guarantee final type is float32
    input_tensor = np.expand_dims(img_data, axis=0).astype(np.float32)

    # 6. Run ONNX Inference
    input_name = session.get_inputs()[0].name
    outputs = session.run(None, {input_name: input_tensor})

    # 7. Get the index of the highest probability and return the matching class name
    predicted_idx = np.argmax(outputs[0])
    return class_names[predicted_idx]