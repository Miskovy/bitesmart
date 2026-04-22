from app.factory import create_app


def test_create_app_registers_expected_routes():
    app = create_app()
    route_paths = {route.path for route in app.router.routes}

    assert "/" in route_paths
    assert "/health" in route_paths
    assert "/health/live" in route_paths
    assert "/health/ready" in route_paths
    assert "/api/v3/predict" in route_paths
    assert "/api/v4/predict" in route_paths
    assert "/api/food/" in route_paths
    assert "/api/coach/chat" in route_paths


def test_create_app_registers_http_middlewares():
    app = create_app()
    middleware_classes = {middleware.cls.__name__ for middleware in app.user_middleware}

    assert "InternalAuthMiddleware" in middleware_classes
    assert "NotFoundHTMLMiddleware" in middleware_classes
    assert "RequestLoggingMiddleware" in middleware_classes
