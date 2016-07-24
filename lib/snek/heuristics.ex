defmodule Snek.Heuristics do
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
