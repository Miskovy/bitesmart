from ultralytics import YOLO

# Load the lightweight Nano segmentation model
model = YOLO('yolov8n-seg.pt')

# Export the model to ONNX format
model.export(format='onnx', dynamic=True)

print("YOLOv8-seg exported successfully!")