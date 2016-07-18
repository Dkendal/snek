defmodule Snek.World do
  @size 20
  @valid_range 0..(@size - 1)

  def set_objects state do
    food_obj = %{"state" => "food"}

    objs = %{}

    objs = Enum.reduce state["food"], objs, fn [y, x], acc ->
      add_at acc, y, x, food_obj
    end

    objs = Enum.reduce state["snakes"], objs, fn snake, acc ->
      name = snake["name"]

      [[y, x] | body] = Enum.uniq snake["coords"]

      acc = add_at acc, y, x, %{"state" => "head", name => name}

      Enum.reduce body, acc, fn [y, x], acc ->
        add_at acc, y, x, %{"state" => "body", name => name}
      end
    end

    snake_dict = Enum.reduce state["snakes"], %{}, fn snake, acc ->
      name = snake["name"]
      put_in acc[name], snake
    end

    state = put_in state[:snake_dict], snake_dict

    state = put_in state["objects"], objs
  end

  def update_board state do
    empty_obj = %{"state" => "empty"}

    state = set_objects state

    board = for y <- @valid_range do
      for x <- @valid_range do
        case state["objects"][y][x] do
          %{} = obj -> obj
          _ -> empty_obj
        end
      end
    end

    state = put_in state["board"], board
  end

  # wall collisions
  def dead?(_state, %{"coords" => [[-1, _] | _]}),
    do: true
  def dead?(_state, %{"coords" => [[_, -1] | _]}),
    do: true
  def dead?(_state, %{"coords" => [[@size, _] | _]}),
    do: true
  def dead?(_state, %{"coords" => [[_, @size] | _]}),
    do: true

  # check for collisions with snake bodies
  def dead?(state, %{"coords" => [head | _]}) do
    Enum.any? state["snakes"], fn %{"coords" => [_ | body]} ->
      Enum.member? body, head
    end
  end

  def bring_out_your_dead state do
    state = update_in state["snakes"], fn snakes ->
      Enum.reduce snakes, [], fn snake, snakes ->
        if dead?(state, snake) do
          snakes
        else
          [snake | snakes]
        end
      end
    end
  end

  def add_at acc, y, x, obj do
    put_in acc, [Access.key(y, %{}), Access.key(x, %{})], obj
  end

  def move(snake, direction) do
    [dy, dx] = case direction do
      "up" ->
        [-1, 0]
      "down" ->
        [1, 0]
      "left" ->
        [0, -1]
      "right" ->
        [0, 1]
    end

    body = snake["coords"]

    [y, x] = hd(body)

    tail = List.delete_at(body, -1)

    new_coords = [[dy + y, dx + x]] ++ tail

    put_in snake["coords"], new_coords
  end
end
