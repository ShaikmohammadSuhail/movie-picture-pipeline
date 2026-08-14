import { render, screen } from "@testing-library/react";
import MovieList from "../MovieList";

test("renders the list of movie titles", () => {
  const movies = [
    { id: "1", title: "Top Gun: Maverick" },
    { id: "2", title: "Sonic the Hedgehog" },
  ];
  render(<MovieList movies={movies} />);
  expect(screen.getByText("Top Gun: Maverick")).toBeInTheDocument();
  expect(screen.getByText("Sonic the Hedgehog")).toBeInTheDocument();
});
