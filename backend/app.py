import os

from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


MOVIES = [
    {"id": "123", "title": "Top Gun: Maverick"},
    {"id": "456", "title": "Sonic the Hedgehog"},
    {"id": "789", "title": "A Quiet Place"},
]


@app.route("/")
def index():
    return jsonify(
        {
            "service": "movie-picture-backend",
            "status": "ok",
            "endpoints": ["/movies", "/health"],
        }
    )


@app.route("/health")
def health():
    return jsonify({"status": "healthy"})


@app.route("/movies")
def movies():
    return jsonify({"movies": MOVIES})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
