from unittest.mock import AsyncMock
from types import SimpleNamespace

from app.constants.ErrorCodes import ErrorCodes
from app.constants.SuccessCodes import SuccessCodes
from app.exceptions.AppException import AppException
from app.exceptions.ValidationException import ValidationException
from app.schemas.prediction import PredictionItem, PredictionResponse
from app.schemas.prediction_v4 import (
    FallbackMeasurements,
    FallbackPredictionData,
    PredictionMacros,
)


def test_prediction_v3_route_requires_auth(prediction_v3_api):
    client, _ = prediction_v3_api

    response = client.post(
        "/api/v3/predict",
        files={"file": ("meal.jpg", b"binary-image", "image/jpeg")},
    )
    payload = response.json()

    assert response.status_code == 401
    assert payload["error_code"] == ErrorCodes.UNAUTHORIZED.name
    assert payload["message"] == "Missing auth headers"


def test_prediction_v3_route_returns_mocked_predictions(prediction_v3_api, monkeypatch, sign_request):
    client, prediction_v3_router_module = prediction_v3_api
    predict_mock = AsyncMock(
        return_value=PredictionResponse(
            top5_predictions=[
                PredictionItem(class_name="salad", confidence=0.91),
                PredictionItem(class_name="pasta", confidence=0.07),
            ],
            image_was_converted=False,
        )
    )
    monkeypatch.setattr(prediction_v3_router_module.prediction_service, "predict_top5", predict_mock)
    client.app.dependency_overrides[prediction_v3_router_module.get_model] = lambda: object()
    client.app.dependency_overrides[prediction_v3_router_module.get_device] = lambda: "cpu"
    client.app.dependency_overrides[prediction_v3_router_module.get_class_names] = lambda: ["salad", "pasta"]

    headers = sign_request("/api/v3/predict", method="POST", multipart=True)
    response = client.post(
        "/api/v3/predict",
        files={"file": ("meal.jpg", b"binary-image", "image/jpeg")},
        headers=headers,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["success_code"] == SuccessCodes.OK.name
    assert payload["message"] == "Prediction completed successfully."
    assert payload["data"]["top5_predictions"][0]["class_name"] == "salad"

    kwargs = predict_mock.await_args.kwargs
    assert kwargs["device"] == "cpu"
    assert kwargs["class_names"] == ["salad", "pasta"]
    assert kwargs["file"].filename == "meal.jpg"


def test_prediction_v3_route_returns_service_unavailable_without_model_state(prediction_v3_api, sign_request):
    client, _ = prediction_v3_api
    headers = sign_request("/api/v3/predict", method="POST", multipart=True)

    response = client.post(
        "/api/v3/predict",
        files={"file": ("meal.jpg", b"binary-image", "image/jpeg")},
        headers=headers,
    )
    payload = response.json()

    assert response.status_code == 503
    assert payload["error_code"] == ErrorCodes.SERVICE_UNAVAILABLE.name
    assert payload["message"] == "Model is not loaded."


def test_prediction_v4_fallback_route_rejects_non_image_files(prediction_v4_api, monkeypatch, sign_request):
    client, prediction_v4_router_module, _ = prediction_v4_api

    def fail_if_called(**kwargs):
        raise AssertionError("prediction service should not be called for invalid files")

    monkeypatch.setattr(
        prediction_v4_router_module.prediction_service,
        "predict_food_volume_fallback",
        fail_if_called,
    )

    headers = sign_request("/api/v4/predict", method="POST", multipart=True)
    response = client.post(
        "/api/v4/predict",
        data={"plate_diameter_cm": "24"},
        files={"file": ("notes.txt", b"not an image", "text/plain")},
        headers=headers,
    )
    payload = response.json()

    assert response.status_code == 400
    assert payload["error_code"] == ErrorCodes.BAD_REQUEST.name
    assert payload["message"] == "File provided is not an image."


def test_prediction_v4_fallback_route_rejects_empty_image_files(prediction_v4_api, monkeypatch, sign_request):
    client, prediction_v4_router_module, _ = prediction_v4_api

    def fail_if_called(**kwargs):
        raise AssertionError("prediction service should not be called for empty files")

    monkeypatch.setattr(
        prediction_v4_router_module.prediction_service,
        "predict_food_volume_fallback",
        fail_if_called,
    )

    headers = sign_request("/api/v4/predict", method="POST", multipart=True)
    response = client.post(
        "/api/v4/predict",
        data={"plate_diameter_cm": "24"},
        files={"file": ("meal.jpg", b"", "image/jpeg")},
        headers=headers,
    )
    payload = response.json()

    assert response.status_code == 400
    assert payload["error_code"] == ErrorCodes.BAD_REQUEST.name
    assert payload["message"] == "File is empty"


def test_prediction_v4_fallback_route_validates_positive_plate_diameter(prediction_v4_api, sign_request):
    client, _, _ = prediction_v4_api
    headers = sign_request("/api/v4/predict", method="POST", multipart=True)

    response = client.post(
        "/api/v4/predict",
        data={"plate_diameter_cm": "0"},
        files={"file": ("meal.jpg", b"binary-image", "image/jpeg")},
        headers=headers,
    )
    payload = response.json()

    assert response.status_code == 422
    assert payload["error_code"] == ErrorCodes.VALIDATION_ERROR.name
    assert payload["details"][0]["field"] == "body -> plate_diameter_cm"


def test_prediction_v4_fallback_route_passes_request_context_to_service(prediction_v4_api, monkeypatch, sign_request):
    client, prediction_v4_router_module, fake_db = prediction_v4_api
    captured = {}

    def fake_predict_food_volume_fallback(**kwargs):
        captured.update(kwargs)
        return FallbackPredictionData(
            food_detected="salad",
            measurements=FallbackMeasurements(
                plate_diameter_cm=24.0,
                estimated_weight_g=180.5,
                estimated_volume_cm3=210.0,
            ),
            macros=PredictionMacros(
                calories=120.0,
                protein_g=6.0,
                carbs_g=12.0,
                fats_g=4.0,
            ),
            training_data_id="training-1",
        )

    monkeypatch.setattr(
        prediction_v4_router_module.prediction_service,
        "predict_food_volume_fallback",
        fake_predict_food_volume_fallback,
    )

    headers = sign_request("/api/v4/predict", method="POST", multipart=True)
    response = client.post(
        "/api/v4/predict",
        data={"plate_diameter_cm": "24", "user_id": "user-7"},
        files={"file": ("meal.jpg", b"binary-image", "image/jpeg")},
        headers=headers,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["success_code"] == SuccessCodes.OK.name
    assert payload["message"] == "Food volume prediction completed successfully."
    assert payload["data"]["training_data_id"] == "training-1"
    assert captured["image_bytes"] == b"binary-image"
    assert captured["plate_diameter_cm"] == 24.0
    assert captured["db"] is fake_db
    assert captured["user_id"] == "user-7"
    assert captured["class_names"] == ["salad", "pizza"]


def test_prediction_v4_ar_route_returns_validation_errors_for_missing_form_fields(prediction_v4_api, sign_request):
    client, _, _ = prediction_v4_api
    headers = sign_request("/api/v4/predictAR", method="POST", multipart=True)

    response = client.post(
        "/api/v4/predictAR",
        files={"file": ("meal.jpg", b"binary-image", "image/jpeg")},
        headers=headers,
    )
    payload = response.json()

    assert response.status_code == 422
    assert payload["error_code"] == ErrorCodes.VALIDATION_ERROR.name
    assert payload["details"][0]["field"] == "body -> food_width_cm"


def test_prediction_v4_ar_route_validates_positive_food_width(prediction_v4_api, sign_request):
    client, _, _ = prediction_v4_api
    headers = sign_request("/api/v4/predictAR", method="POST", multipart=True)

    response = client.post(
        "/api/v4/predictAR",
        data={"food_width_cm": "-1"},
        files={"file": ("meal.jpg", b"binary-image", "image/jpeg")},
        headers=headers,
    )
    payload = response.json()

    assert response.status_code == 422
    assert payload["error_code"] == ErrorCodes.VALIDATION_ERROR.name
    assert payload["details"][0]["field"] == "body -> food_width_cm"


def test_prediction_v4_ar_route_surfaces_service_errors(prediction_v4_api, monkeypatch, sign_request):
    client, prediction_v4_router_module, _ = prediction_v4_api

    def fake_predict_food_volume_ar(**kwargs):
        raise AppException(ErrorCodes.INTERNAL_ERROR, "Class salad missing from database.")

    monkeypatch.setattr(
        prediction_v4_router_module.prediction_service,
        "predict_food_volume_ar",
        fake_predict_food_volume_ar,
    )

    headers = sign_request("/api/v4/predictAR", method="POST", multipart=True)
    response = client.post(
        "/api/v4/predictAR",
        data={"food_width_cm": "8.5"},
        files={"file": ("meal.jpg", b"binary-image", "image/jpeg")},
        headers=headers,
    )
    payload = response.json()

    assert response.status_code == 500
    assert payload["error_code"] == ErrorCodes.INTERNAL_ERROR.name
    assert payload["message"] == "Class salad missing from database."


def test_predict_food_volume_fallback_returns_validation_error_when_plate_detection_fails(monkeypatch):
    from app.services import prediction_service

    monkeypatch.setattr(prediction_service, "process_image", lambda *args, **kwargs: "salad")
    monkeypatch.setattr(prediction_service, "extract_food_mask", lambda *args, **kwargs: (1250.0, 100.0))
    monkeypatch.setattr(prediction_service, "get_plate_diameter_cv2", lambda *args, **kwargs: (0.0, 0.0))

    fake_db = SimpleNamespace(query=lambda *args, **kwargs: (_ for _ in ()).throw(AssertionError("db should not be queried")))

    try:
        prediction_service.predict_food_volume_fallback(
            image_bytes=b"fake-image",
            plate_diameter_cm=24.0,
            convnext_session=object(),
            class_names=["salad"],
            yolo_model=object(),
            db=fake_db,
            user_id="user-1",
        )
        raise AssertionError("Expected ValidationException to be raised")
    except ValidationException as exc:
        assert exc.error_code == ErrorCodes.VALIDATION_ERROR.name
        assert exc.message == "Plate detection not valid: Could not detect a circular plate. Please ensure the plate is fully visible."
