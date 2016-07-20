defmodule Snek.World do
  @size 20
  @valid_range 0..(@size - 1)
  @up [-1, 0]
  @down [1, 0]
  @left [0, -1]
  @right [0, 1]
  @food %{"state" => "food"}

  def new(params) do
    default = %{
      "snakes" => [],
      "food" => [],
    }

    Dict.merge default, params
  end

  # set :rows and :cols on world state
  def set_dimensions state do
    rows = length state["board"]
    cols = length hd state["board"]

    state
    |> put_in([:rows], rows)
    |> put_in([:cols], cols)
  end

  def set_objects state do

    objs = %{}

    objs = Enum.reduce state["food"], objs, fn [y, x], acc ->
      add_at acc, y, x, @food
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

  def step(state) do
    state
    |> clean_up_dead
    |> grow_snakes
    |> remove_eaten_food
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

  def clean_up_dead state do
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

  def grow_snakes state do
    state = update_in state["snakes"], fn snakes ->
      for snake <- snakes do
        increase = grew(state, snake)

        update_in snake["coords"], fn coords ->
          last = List.last coords
          new_segments = for i <- 0..increase, i > 0, do: last
          coords ++ new_segments
        end
      end
    end
  end

  def remove_eaten_food(state) do
    update_in state["food"], fn food ->
      Enum.reject food, &eaten?(state, &1)
    end
  end

  def eaten?(state, apple) do
    Enum.any? state["snakes"], fn
      %{"coords" => [^apple | _]} ->
        true
      _ ->
        false
    end
  end


  def grew(state, snake) do
    head = hd snake["coords"]

    if head in state["food"] do
      1
    else
      0
    end
  end

  def add_at acc, y, x, obj do
    put_in acc, [Access.key(y, %{}), Access.key(x, %{})], obj
  end

  def move(snake, direction) do
    [dy, dx] = case direction do
      "up" ->
        @up
      "down" ->
        @down
      "left" ->
        @left
      "right" ->
        @right
    end

    body = snake["coords"]

    [y, x] = hd(body)

    tail = List.delete_at(body, -1)

    new_coords = [[dy + y, dx + x]] ++ tail

    put_in snake["coords"], new_coords
  end
end
