from fastapi import status, Request
from fastapi.exceptions import HTTPException

def get_model(request: Request):
    if not hasattr(request.app.state, "model"):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Model is not loaded."
        )
    return request.app.state.model

def get_device(request: Request):
    if not hasattr(request.app.state, "device"):
        return "cpu"  # Default to CPU if not found
    return request.app.state.device

def get_class_names(request: Request):
    if not hasattr(request.app.state, "class_names"):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Class names are not loaded."
        )
    return request.app.state.class_names