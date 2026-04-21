import asyncio
from contextlib import suppress
from datetime import datetime, timezone

from fastapi import FastAPI


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _isoformat(value: datetime) -> str:
    return value.isoformat()


def initialize_health_state(app: FastAPI) -> None:
    app.state.health_started_at = _utcnow()
    app.state.health_ready = False
    app.state.health_startup_error = None
    app.state.health_snapshot = {}
    app.state.health_refresh_task = None
    refresh_health_snapshot(app)


def mark_ready(app: FastAPI) -> None:
    app.state.health_ready = True
    app.state.health_startup_error = None
    refresh_health_snapshot(app)


def mark_startup_failure(app: FastAPI, exc: Exception) -> None:
    app.state.health_ready = False
    app.state.health_startup_error = str(exc)
    refresh_health_snapshot(app)


def build_dashboard_snapshot(app: FastAPI) -> dict:
    started_at = getattr(app.state, "health_started_at", _utcnow())
    now = _utcnow()

    class_names_loaded = hasattr(app.state, "class_names")
    convnext_loaded = hasattr(app.state, "convnext_session")
    yolo_ar_loaded = hasattr(app.state, "yolo_ar_model")
    ready = bool(getattr(app.state, "health_ready", False))
    startup_error = getattr(app.state, "health_startup_error", None)

    if startup_error:
        status = "error"
    elif ready:
        status = "ok"
    else:
        status = "starting"

    return {
        "status": status,
        "ready": ready,
        "model_loaded": convnext_loaded,
        "components": {
            "class_names_loaded": class_names_loaded,
            "convnext_loaded": convnext_loaded,
            "yolo_ar_loaded": yolo_ar_loaded,
        },
        "startup_error": startup_error,
        "started_at": _isoformat(started_at),
        "last_updated": _isoformat(now),
        "uptime_seconds": max(0, int((now - started_at).total_seconds())),
    }


def refresh_health_snapshot(app: FastAPI) -> dict:
    snapshot = build_dashboard_snapshot(app)
    app.state.health_snapshot = snapshot
    return snapshot


def get_health_snapshot(app: FastAPI) -> dict:
    snapshot = getattr(app.state, "health_snapshot", None)
    if snapshot:
        return snapshot

    return refresh_health_snapshot(app)


def build_liveness_payload(app: FastAPI) -> dict:
    snapshot = get_health_snapshot(app)
    return {
        "status": "alive",
        "started_at": snapshot["started_at"],
        "uptime_seconds": snapshot["uptime_seconds"],
    }


def build_readiness_payload(app: FastAPI) -> dict:
    snapshot = get_health_snapshot(app)
    return {
        "status": "ready" if snapshot["ready"] else "not_ready",
        "ready": snapshot["ready"],
        "startup_error": snapshot["startup_error"],
        "last_updated": snapshot["last_updated"],
        "components": snapshot["components"],
    }


async def run_health_refresh_loop(app: FastAPI, interval_seconds: int) -> None:
    while True:
        refresh_health_snapshot(app)
        await asyncio.sleep(interval_seconds)


def start_health_refresh_task(app: FastAPI, interval_seconds: int) -> asyncio.Task:
    refresh_health_snapshot(app)
    task = asyncio.create_task(run_health_refresh_loop(app, interval_seconds))
    app.state.health_refresh_task = task
    return task


async def stop_health_refresh_task(app: FastAPI) -> None:
    task = getattr(app.state, "health_refresh_task", None)
    if task is None:
        return

    task.cancel()
    with suppress(asyncio.CancelledError):
        await task
    app.state.health_refresh_task = None
