# local representation of a world state, with the name of the snake enocoded
defmodule Snek.Local do
  defstruct [
    :name, # name of this snake
    :world, # game state
    moves: [],
    size: 0,
    utility: %{}
  ]

  def score local do
    get_in(local.utility, [Access.key(local.name, 0.0)])
  end

  def size(local) do
    length(coords(local))
  end

  def coords(local) do
    this(local)["coords"]
  end

  @dead %{
    "coords" => []
  }

  # returns this snake
  def this local do
    local.world.snake_map[local.name] || @dead
  end

  def heuristic local do
    free_space = FloodFill.flood_fill_count(local)
  end
end
