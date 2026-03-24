from fastapi import status, Request
from fastapi.exceptions import HTTPException

def get_convnext_session(request: Request):
    if not hasattr(request.app.state, "convnext_session"):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="ConvNeXt ONNX session is not loaded."
        )
    return request.app.state.convnext_session

def get_yolo_session(request: Request):
    if not hasattr(request.app.state, "yolo_session"):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="YOLO ONNX session is not loaded."
        )
    return request.app.state.yolo_session

def get_class_names(request: Request):
    if not hasattr(request.app.state, "class_names"):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Class names are not loaded."
        )
    return request.app.state.class_names