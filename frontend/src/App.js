import React, { useEffect, useState } from "react";
import MovieList from "./components/MovieList";

const API_URL = process.env.REACT_APP_MOVIE_API_URL || "http://localhost:5000";

function App() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    fetch(`${API_URL}/movies`)
      .then((res) => res.json())
      .then((data) => {
        if (!cancelled) {
          setMovies(data.movies || []);
          setLoading(false);
        }
      })
      .catch(() => {
        if (!cancelled) {
          setLoading(false);
        }
      });
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>Movie Picture</h1>
      </header>
      <main>
        {loading ? (
          <p data-testid="loading">Loading movies...</p>
        ) : (
          <MovieList movies={movies} />
        )}
      </main>
    </div>
  );
}

export default App;
