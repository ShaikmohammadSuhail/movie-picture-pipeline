import pytest

from app import app


@pytest.fixture
def client():
    app.config.update(TESTING=True)
    with app.test_client() as client:
        yield client


def test_movies_endpoint_returns_200(client):
    response = client.get("/movies")
    assert response.status_code == 200


def test_movies_endpoint_returns_json(client):
    response = client.get("/movies")
    data = response.get_json()
    assert isinstance(data, dict)
    assert "movies" in data


def test_movies_endpoint_returns_valid_data(client):
    response = client.get("/movies")
    data = response.get_json()
    movies = data["movies"]
    assert isinstance(movies, list)
    assert len(movies) == 3
    for movie in movies:
        assert "id" in movie
        assert "title" in movie
    assert movies[0]["title"] == "Top Gun: Maverick"
