from datetime import timedelta, timezone
from zoneinfo import ZoneInfoNotFoundError


def test_today_window_in_app_timezone_uses_midnight_bounds(monkeypatch):
    from app.config.config import settings
    from app.services import coach_service

    monkeypatch.setattr(settings, "APP_TIMEZONE", "UTC")
    monkeypatch.setattr(coach_service, "ZoneInfo", lambda key: timezone.utc)

    start_of_day, end_of_day = coach_service._today_window_in_app_timezone()

    assert start_of_day.hour == 0
    assert start_of_day.minute == 0
    assert start_of_day.second == 0
    assert start_of_day.microsecond == 0
    assert end_of_day - start_of_day == timedelta(days=1)


def test_today_window_in_app_timezone_falls_back_to_utc_for_invalid_timezone(monkeypatch, caplog):
    from app.config.config import settings
    from app.services import coach_service

    monkeypatch.setattr(settings, "APP_TIMEZONE", "Not/A_Real_Timezone")
    monkeypatch.setattr(
        coach_service,
        "ZoneInfo",
        lambda key: (_ for _ in ()).throw(ZoneInfoNotFoundError(key)),
    )

    start_of_day, end_of_day = coach_service._today_window_in_app_timezone()

    assert end_of_day - start_of_day == timedelta(days=1)
    assert "Falling back to UTC" in caplog.text
