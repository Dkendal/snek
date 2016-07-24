# local representation of a world state, with the name of the snake enocoded
defmodule Snek.Local do
  alias Snek.{World}

  import Snek.Heuristics

  defstruct [
    :name, # name of this snake
    :world, # game state
    moves: [],
    size: 0,
    utility: %{}
  ]

  def step local, moves do
    update_in(local.world, fn state ->
      state
      |> World.apply_moves(moves)
      |> World.step()
      |> World.set_objects()
    end)
    |> update_utility
  end

  # update the fitness of all snakes on this forecasted turn
  def update_utility local do
    world = local.world

    snakes = world["snakes"]

    utility = Enum.reduce snakes, %{}, fn snake, acc ->
      name = snake["name"]

      val = utility(world, snake)

      put_in acc[name], val
    end

    put_in(local.utility, utility)
  end

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
