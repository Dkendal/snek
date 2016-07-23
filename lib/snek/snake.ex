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
end
