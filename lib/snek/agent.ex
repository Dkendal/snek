defmodule Snek.Agent do
  alias Vector, as: V

  @moves [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0],
  ]

  @name "Snek"

   def move(state) do
     food = food(state)
     next = next(state)

     direction(state, next)
   end

  def direction(state, v) do
    case V.sub(head(state), v) do
      [0, 1] ->
        "left"
      [1, 0] ->
        "up"
      [0, -1] ->
        "right"
      [-1, 0] ->
        "down"
    end
  end

  def next(state) do
    f = frontier(state)
    v = remove_collisions(state, f)
    best_choice(state, v, f)
  end

  # out of options, next move is death
  def best_choice(state, [], [v | _]) do
    v
  end

  def best_choice(state, nodes, _frontier) do
    Enum.max_by(nodes, fn v -> utility(state, v) end)
  end

  def utility(state, v) do
    d = Enum.min Stream.map(food(state), fn apple ->
      V.distance(apple, v)
    end)

    if d == 0, do: 1, else: 1.0/d
  end

  def frontier(state) do
    pos = head(state)

    moves = Enum.map @moves, fn v ->
      V.add(v, pos)
    end
  end

  def remove_collisions(state, moves) do
    moves = Enum.reject moves, & wall?(state, &1)
    moves -- tail(state)
  end

  def food(state) do
    state["food"]
  end

  def head(state) do
    hd coords(state)
  end

  def tail(state) do
    tl coords(state)
  end

  def coords(state) do
    this(state)["coords"]
  end

  def this(state) do
    state.snake_map[@name]
  end

  def wall?(state, [_, -1]), do: true
  def wall?(state, [-1, _]), do: true
  def wall?(state, [y, x]) do
    max = length(state["board"])
    x == max || y == max
  end
end
