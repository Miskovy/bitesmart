import onnxruntime as ort
import numpy as np
from pathlib import Path

# Path to your new ONNX model
ONNX_PATH = Path(__file__).resolve().parent.parent.parent / "storage" / "models" / "v3" / "convnext_base_119.onnx"

try:
    # 1. Load the model into ONNX Runtime
    session = ort.InferenceSession(str(ONNX_PATH))
    print("✅ ONNX model loaded successfully!")

    # 2. Inspect the expected input and output names
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name
    print(f"Input node name: {input_name}")
    print(f"Output node name: {output_name}")

    # 3. Run a dummy prediction to ensure the math graph executes
    dummy_input = np.random.randn(1, 3, 224, 224).astype(np.float32)
    predictions = session.run([output_name], {input_name: dummy_input})

    print(f"✅ Dummy prediction successful! Output shape: {predictions[0].shape}")

except Exception as e:
    print(f"❌ Error loading model: {e}")