import React from "react";

function MovieList({ movies }) {
  if (!movies || movies.length === 0) {
    return <p>No movies available.</p>;
  }
  return (
    <ul>
      {movies.map((movie) => (
        <li key={movie.id}>{movie.title}</li>
      ))}
    </ul>
  );
}

export default MovieList;
