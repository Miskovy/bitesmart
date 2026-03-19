import torch
import timm
from pathlib import Path
from typing import List
from app.config.config import settings

def load_class_names(class_list_path: Path) -> List[str]:
    if not class_list_path.exists():
        raise FileNotFoundError(f"Class list file not found: {class_list_path}")
    print(f"Loading class list from {class_list_path}")
    with open(class_list_path, "r") as f:
        class_names = [line.strip() for line in f.readlines()]

    print(f"Loaded {len(class_names)} class names.")

    return class_names

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