from fastapi import Request

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException


def get_convnext_session(request: Request):
    if not hasattr(request.app.state, "convnext_session"):
        raise AppException(ErrorCodes.SERVICE_UNAVAILABLE, "ConvNeXt ONNX session is not loaded.")
    return request.app.state.convnext_session


def get_yolo_session(request: Request):
    if not hasattr(request.app.state, "yolo_session"):
        raise AppException(ErrorCodes.SERVICE_UNAVAILABLE, "YOLO ONNX session is not loaded.")
    return request.app.state.yolo_session


def get_class_names(request: Request):
    if not hasattr(request.app.state, "class_names"):
        raise AppException(ErrorCodes.SERVICE_UNAVAILABLE, "Class names are not loaded.")
    return request.app.state.class_names
