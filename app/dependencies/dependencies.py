from fastapi import Request

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException


def get_model(request: Request):
    if not hasattr(request.app.state, "model"):
        raise AppException(ErrorCodes.SERVICE_UNAVAILABLE, "Model is not loaded.")
    return request.app.state.model


def get_device(request: Request):
    if not hasattr(request.app.state, "device"):
        return "cpu"
    return request.app.state.device


def get_class_names(request: Request):
    if not hasattr(request.app.state, "class_names"):
        raise AppException(ErrorCodes.SERVICE_UNAVAILABLE, "Class names are not loaded.")
    return request.app.state.class_names
