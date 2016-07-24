defmodule Snek.Agent do
  alias Snek.{World, Local}
  alias Vector, as: V

  import Snek.Heuristics

  @lookahead 2

  @directions ~W(up down left right)

  def move(state, name) do
    state = World.set_dimensions state
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

  def search(local, 0) do
    [local]
  end

  def search(local, depth) do
    coords = Local.this(local)["coords"]

    ignore = case coords do
      [a, b |_] ->
        V.sub(a, b)

      _ ->
        []
    end

    dir = @directions -- ignore

    Enum.flat_map dir, fn dir ->
      local = update_in local.moves, fn moves ->
        [dir | moves]
      end

      moves = %{local.name => dir}

      local = Local.step local, moves

      initial_size = local.size

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
