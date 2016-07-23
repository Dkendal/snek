defmodule Snek.Agent do
  alias Snek.{World, Local}
  alias Vector, as: V

  @directions ~W(up down left right)

  def move(state, name) do
    state = World.set_dimensions state
    state = put_in state["board"], nil

    local = %Local{
      name: name,
      world: state,
    }

    size = length(Local.this(local)["coords"])

    local = put_in local.size, size

    move local
  end

  defp move(local) do
    locals = search(local, 2)
    IO.inspect length locals

    local = best_move locals

    List.last local.moves
  end

  def best_move(locals) do
    Enum.max_by locals, &h/1
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

      local = update_in local.world, fn state ->
        state
        |> World.apply_moves(%{local.name => dir})
        |> World.step()
        |> World.set_objects()
      end

      snakes = local.world["snakes"]

      world = local.world

      utility = Enum.reduce snakes, %{}, fn snake, acc ->
        name = snake["name"]

        val = utility(world, snake)

        put_in acc[name], val
      end

      local = put_in(local.utility, utility)

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

  def utility(state, snake) do
    len = length(snake["coords"])
    dist = distance_from_food(state, snake)

    d = if dist == 0, do: 1, else: 1 / dist
    0.0 + d + len
  end

 def distance_from_food(state, snake) do
    head = hd snake["coords"]
    food = state["food"]

    distance_from_food(head: head, food: food)
  end

  def distance_from_food(head: _, food: []) do
    0
  end

  def distance_from_food(head: head, food: food) do
     Enum.min Stream.map(food, fn apple ->
       manhatten(head, apple)
    end)
  end

  def manhatten [y, x], [y2, x2] do
    abs(y2 - y) + abs(x2 - x)
  end
end
