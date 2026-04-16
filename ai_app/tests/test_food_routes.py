from types import SimpleNamespace

from app.constants.ErrorCodes import ErrorCodes
from app.constants.SuccessCodes import SuccessCodes
from app.exceptions.ConflictException import ConflictException
from app.exceptions.NotFound import NotFoundException
from app.schemas.food_schema import PaginatedFoodResponse


def make_food_item(food_id: int = 1, class_name: str = "salad"):
    return SimpleNamespace(
        id=food_id,
        class_name=class_name,
        avg_height_cm=2.5,
        density_g_cm3=0.8,
        protein_per_100g=4.0,
        carbs_per_100g=8.0,
        fats_per_100g=2.0,
        cals_per_100g=70.0,
    )


def test_list_foods_route_returns_paginated_response(food_api, monkeypatch):
    client, food_router_module, fake_db = food_api
    expected_result = PaginatedFoodResponse(
        total_items=1,
        total_pages=1,
        current_page=2,
        limit=5,
        data=[make_food_item()],
    )

    captured = {}

    def fake_list_foods(db, page, limit, search):
        captured.update({"db": db, "page": page, "limit": limit, "search": search})
        return expected_result

    monkeypatch.setattr(food_router_module.food_service, "list_foods", fake_list_foods)

    response = client.get("/api/food/", params={"page": 2, "limit": 5, "search": "sal"})
    payload = response.json()

    assert response.status_code == 200
    assert payload["success_code"] == SuccessCodes.OK.name
    assert payload["message"] == "Food items loaded successfully."
    assert payload["data"]["current_page"] == 2
    assert payload["data"]["data"][0]["class_name"] == "salad"
    assert captured == {"db": fake_db, "page": 2, "limit": 5, "search": "sal"}


def test_list_foods_route_validates_query_params(food_api):
    client, _, _ = food_api

    response = client.get("/api/food/", params={"page": 0})
    payload = response.json()

    assert response.status_code == 422
    assert payload["error_code"] == ErrorCodes.VALIDATION_ERROR.name
    assert payload["details"][0]["field"] == "query -> page"
    assert "greater than or equal to 1" in payload["details"][0]["message"]


def test_get_food_by_id_returns_not_found_when_service_raises(food_api, monkeypatch):
    client, food_router_module, fake_db = food_api

    def fake_get_food_or_raise(db, food_id):
        assert db is fake_db
        assert food_id == 99
        raise NotFoundException("Food item", food_id)

    monkeypatch.setattr(food_router_module.food_service, "get_food_or_raise", fake_get_food_or_raise)

    response = client.get("/api/food/99")
    payload = response.json()

    assert response.status_code == 404
    assert payload["error_code"] == ErrorCodes.NOT_FOUND.name
    assert payload["message"] == "Food item not found: 99"
    assert payload["path"] == "/api/food/99"


def test_create_food_route_returns_created_resource(food_api, monkeypatch):
    client, food_router_module, fake_db = food_api
    created_food = make_food_item(food_id=7, class_name="oats")
    captured = {}

    def fake_create_food(db, food_in):
        captured["db"] = db
        captured["food_in"] = food_in
        return created_food

    monkeypatch.setattr(food_router_module.food_service, "create_food", fake_create_food)

    request_body = {
        "class_name": "oats",
        "avg_height_cm": 1.2,
        "density_g_cm3": 0.5,
        "protein_per_100g": 16.9,
        "carbs_per_100g": 66.3,
        "fats_per_100g": 6.9,
        "cals_per_100g": 389.0,
    }
    response = client.post("/api/food/", json=request_body)
    payload = response.json()

    assert response.status_code == 201
    assert payload["success_code"] == SuccessCodes.CREATED.name
    assert payload["data"]["id"] == 7
    assert captured["db"] is fake_db
    assert captured["food_in"].class_name == "oats"
    assert captured["food_in"].cals_per_100g == 389.0


def test_create_food_route_returns_conflict_from_service(food_api, monkeypatch):
    client, food_router_module, _ = food_api

    def fake_create_food(db, food_in):
        raise ConflictException(f"Food item with class name '{food_in.class_name}' already exists.")

    monkeypatch.setattr(food_router_module.food_service, "create_food", fake_create_food)

    response = client.post(
        "/api/food/",
        json={
            "class_name": "oats",
            "avg_height_cm": 1.2,
            "density_g_cm3": 0.5,
            "protein_per_100g": 16.9,
            "carbs_per_100g": 66.3,
            "fats_per_100g": 6.9,
            "cals_per_100g": 389.0,
        },
    )
    payload = response.json()

    assert response.status_code == 409
    assert payload["error_code"] == ErrorCodes.CONFLICT.name
    assert "already exists" in payload["message"]


def test_delete_food_route_returns_no_content(food_api, monkeypatch):
    client, food_router_module, fake_db = food_api
    captured = {}

    def fake_delete_food(db, food_id):
        captured.update({"db": db, "food_id": food_id})

    monkeypatch.setattr(food_router_module.food_service, "delete_food", fake_delete_food)

    response = client.delete("/api/food/3")

    assert response.status_code == 204
    assert response.content == b""
    assert captured == {"db": fake_db, "food_id": 3}


def test_food_get_routes_remain_public_when_auth_middleware_is_enabled(food_protected_api, monkeypatch):
    client, food_router_module, fake_db = food_protected_api

    def fake_list_foods(db, page, limit, search):
        assert db is fake_db
        return PaginatedFoodResponse(
            total_items=1,
            total_pages=1,
            current_page=1,
            limit=10,
            data=[make_food_item()],
        )

    monkeypatch.setattr(food_router_module.food_service, "list_foods", fake_list_foods)

    response = client.get("/api/food/")

    assert response.status_code == 200
    assert response.json()["success_code"] == SuccessCodes.OK.name


def test_food_mutations_require_internal_auth_when_middleware_is_enabled(food_protected_api):
    client, _, _ = food_protected_api

    response = client.post(
        "/api/food/",
        json={
            "class_name": "oats",
            "avg_height_cm": 1.2,
            "density_g_cm3": 0.5,
            "protein_per_100g": 16.9,
            "carbs_per_100g": 66.3,
            "fats_per_100g": 6.9,
            "cals_per_100g": 389.0,
        },
    )
    payload = response.json()

    assert response.status_code == 401
    assert payload["error_code"] == ErrorCodes.UNAUTHORIZED.name
    assert payload["message"] == "Missing auth headers"
