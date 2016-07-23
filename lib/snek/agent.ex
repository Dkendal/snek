defmodule Snek.Agent do
  alias Snek.{World, Local}
  alias Vector, as: V

  @directions ~W(up down left right)

  def move(state, name) do
    state = World.set_dimensions state
    state = put_in state["board"], nil
    move %Local{
      name: name,
      world: state,
    }
  end

  defp move(local) do
    locals = search(local, 3)

    local = Enum.max_by locals, fn local ->
      Local.score(local) + Local.heuristic(local)
    end

    List.last local.moves
  end

  def search(local, 0) do
    [local]
  end

  def search(local, depth) do
    Enum.flat_map @directions, fn dir ->
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

      if Local.score(local) <= 0 do
        # don't expand nodes that result in death
        [local]
      else
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
      V.distance(apple, head)
    end)
  end
end
