defmodule Snek.Snake do
  def new(params, rows, cols) do
    starting_pos = [:rand.uniform(rows), :rand.uniform(cols)]

    coords = (for _ <- 0..3, do: starting_pos)

    default = %{
      "color" => "",
      "coords" => coords,
      "head_url" => "",
      "name" => "",
      "taunt" => "",
      "url" => "",
    }

    Dict.merge default, params
  end

  def len(snake) do
    length snake["coords"]
  end

  def grow(snake, size) do
    update_in snake["coords"], fn coords ->
      last = List.last coords
      new_segments = for i <- 0..size, i > 0, do: last
      coords ++ new_segments
    end
  end
end
