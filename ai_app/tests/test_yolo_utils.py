import numpy as np


def _stub_plate_detection(monkeypatch, yolo_utils):
    monkeypatch.setattr(yolo_utils.cv2, "imdecode", lambda *args, **kwargs: np.zeros((10, 10, 3), dtype=np.uint8))
    monkeypatch.setattr(yolo_utils.cv2, "cvtColor", lambda image, code: np.zeros((10, 10), dtype=np.uint8))

    class FakeClahe:
        def apply(self, gray):
            return gray

    monkeypatch.setattr(yolo_utils.cv2, "createCLAHE", lambda *args, **kwargs: FakeClahe())
    monkeypatch.setattr(yolo_utils.cv2, "medianBlur", lambda image, ksize: image)
    monkeypatch.setattr(yolo_utils.cv2, "Canny", lambda image, low, high: image)
    monkeypatch.setattr(yolo_utils.cv2, "getStructuringElement", lambda *args, **kwargs: np.ones((1, 1), dtype=np.uint8))
    monkeypatch.setattr(yolo_utils.cv2, "dilate", lambda image, kernel, iterations=1: image)
    monkeypatch.setattr(
        yolo_utils.cv2,
        "findContours",
        lambda *args, **kwargs: ([np.ones((5, 1, 2), dtype=np.float32)], None),
    )
    monkeypatch.setattr(yolo_utils.cv2, "contourArea", lambda contour: 25001)
    monkeypatch.setattr(yolo_utils.cv2, "fitEllipse", lambda contour: ((0.0, 0.0), (20.0, 10.0), 0.0))
    monkeypatch.setattr(yolo_utils.cv2, "ellipse", lambda *args, **kwargs: None)


def test_get_plate_diameter_does_not_write_debug_image_when_env_flag_is_disabled(monkeypatch):
    from app.config.config import settings
    from app.utils import yolo_utils

    monkeypatch.setattr(settings, "PLATE_DEBUG_IMAGES", False)
    _stub_plate_detection(monkeypatch, yolo_utils)
    monkeypatch.setattr(yolo_utils.os, "makedirs", lambda *args, **kwargs: (_ for _ in ()).throw(AssertionError("makedirs should not be called")))
    monkeypatch.setattr(yolo_utils.cv2, "imwrite", lambda *args, **kwargs: (_ for _ in ()).throw(AssertionError("imwrite should not be called")))

    major_axis, minor_axis = yolo_utils.get_plate_diameter_cv2(b"fake-image")

    assert (major_axis, minor_axis) == (20.0, 10.0)


def test_get_plate_diameter_writes_debug_image_when_env_flag_is_enabled(monkeypatch):
    from app.config.config import settings
    from app.utils import yolo_utils

    calls = {"makedirs": 0, "imwrite": 0}

    monkeypatch.setattr(settings, "PLATE_DEBUG_IMAGES", True)
    _stub_plate_detection(monkeypatch, yolo_utils)
    monkeypatch.setattr(yolo_utils.os, "makedirs", lambda *args, **kwargs: calls.__setitem__("makedirs", calls["makedirs"] + 1))
    monkeypatch.setattr(yolo_utils.cv2, "imwrite", lambda *args, **kwargs: calls.__setitem__("imwrite", calls["imwrite"] + 1))

    major_axis, minor_axis = yolo_utils.get_plate_diameter_cv2(b"fake-image")

    assert (major_axis, minor_axis) == (20.0, 10.0)
    assert calls["makedirs"] == 1
    assert calls["imwrite"] == 1
