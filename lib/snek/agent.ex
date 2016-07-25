defmodule Snek.Agent do
  alias Snek.{World, Local}
  alias Vector, as: V

  import Snek.Heuristics

  @lookahead 2

  @directions ~W(up down left right)

  def move(state, name) do
    state = World.Map.set_objects World.set_dimensions state
    state = put_in state["board"], nil

    local = %Local{
      name: name,
      world: state,
    }

    size = Local.size(local)

    local = put_in local.size, size

    move local
  end

  defp move(local) do
    locals = search(local, 1)

    best_move locals
  end

  def best_move([]) do
    Enum.random @directions
  end

  def best_move(locals) do
    local = Enum.max_by(locals, &h/1)
    List.last(local.moves)
  end

  def h local do
    f = Local.heuristic(local)
    m = (1 / length(local.moves))
    s = Local.score(local)
    s + m + f
  end

  def cartesian [] do
    []
  end

  def cartesian [a] do
    for x <- a, do: [x]
  end

  def cartesian [a, b | t] do
    cartesian(cartesian(a, b), t)
  end

  def cartesian(a, []) do
    a
  end

  def cartesian(a, [b | t]) when is_list(b) do
    val = for x <- a, y <- b, do: x++[y]
    cartesian(val, t)
  end

  def cartesian a, b do
    for x <- a, y <- b, do: [x, y]
  end

  def search(local, 0) do
    [local]
  end

  def search(local, depth) do
    initial_size = local.size

    coords = Local.coords(local)

    dir = @directions

    snakes = local.world["snakes"]

    moves =
      for s <- snakes,
      do: for d <- @directions, do: {s["name"], d}

    moves = cartesian moves

    Enum.flat_map moves, fn moves ->
      moves = Enum.into moves, %{}
      dir = moves[local.name]

      local = update_in local.moves, fn moves ->
        [dir | moves]
      end

      local = Local.step local, moves

      case Local.size(local) do
        0 ->
          # don't expand nodes that result in death
          []

        x when x > initial_size ->
          # don't expand nodes any further on terminal nodes
          [local]

        _ ->
          search(local, depth - 1)
      end
    end
  end
end
