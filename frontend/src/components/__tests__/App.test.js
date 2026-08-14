import { render, screen } from "@testing-library/react";
import App from "../../App";

beforeEach(() => {
  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () =>
        Promise.resolve({
          movies: [
            { id: "123", title: "Top Gun: Maverick" },
            { id: "456", title: "Sonic the Hedgehog" },
            { id: "789", title: "A Quiet Place" },
          ],
        }),
    })
  );
});

test("renders the Movie Picture heading", () => {
  render(<App />);
  expect(screen.getByText("Movie Picture")).toBeInTheDocument();
});

test("renders the movies fetched from the API", async () => {
  render(<App />);
  expect(await screen.findByText("Top Gun: Maverick")).toBeInTheDocument();
  expect(screen.getByText("Sonic the Hedgehog")).toBeInTheDocument();
  expect(screen.getByText("A Quiet Place")).toBeInTheDocument();
});
