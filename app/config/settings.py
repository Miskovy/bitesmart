from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
# MODEL_NAME = "vit_base_patch16_224.orig_in21k"
MODEL_NAME = "convnext_base.fb_in22k"
# MODEL_PATH = PROJECT_ROOT / "storage" / "models" / "v2" / "food_V2_model.pth"
MODEL_PATH = PROJECT_ROOT / "storage" / "models" / "v3" / "food_V3_convnext.pth"
CLASS_LIST_PATH = PROJECT_ROOT / "storage" / "data" / "food_119_classes.txt"

NUM_CLASSES = 119
IMG_SIZE = 224