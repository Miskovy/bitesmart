import torch
import timm
from pathlib import Path

# 1. Define paths based on your current FastAPI structure
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
WEIGHTS_PATH = PROJECT_ROOT / "storage" / "models" / "v3" / "food_V3_convnext.pth"
ONNX_OUTPUT_PATH = PROJECT_ROOT / "storage" / "models" / "v4" / "convnext" / "convnext_base_119.onnx"

print(f"Loading weights from: {WEIGHTS_PATH}")

# 2. Recreate the exact architecture using timm
# We set pretrained=False because we are loading your custom weights
model = timm.create_model(
    "convnext_base.fb_in22k",
    pretrained=False,
    num_classes=119
)

# 3. Load trained weights onto the CPU
state_dict = torch.load(WEIGHTS_PATH, map_location='cpu')
model.load_state_dict(state_dict)
model.eval() # Crucial: set to evaluation mode

# 4. Create a dummy input tensor matching config (IMG_SIZE: 224)
dummy_input = torch.randn(1, 3, 224, 224)

print("Exporting model to ONNX...")

# 5. Export to ONNX
torch.onnx.export(
    model,
    dummy_input,
    str(ONNX_OUTPUT_PATH),
    export_params=True,
    opset_version=14,
    do_constant_folding=True,
    input_names=['input'],
    output_names=['output'],
    dynamic_axes={
        'input': {0: 'batch_size'},
        'output': {0: 'batch_size'}
    }
)

print(f"Success! ONNX model saved to: {ONNX_OUTPUT_PATH}")