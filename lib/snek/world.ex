defmodule Snek.World do
  alias Snek.{Snake, Board}

  def new(params, width: width, height: height) do
    board = Board.new(width, height)

    default = %{
      "snakes" => [],
      "food" => [],
      "board" => board
    }

    Dict.merge default, params
  end

  def up,     do: [0, -1]
  def down,   do: [0,  1]
  def right,  do: [1,  0]
  def left,   do: [-1,  0]

  def moves do
    [
      up,
      down,
      left,
      right,
    ]
  end

  # set :rows and :cols on world state
  def set_dimensions state do
    board = board(state)
    rows = length board
    cols = length hd board

    state
    |> put_in([:rows], rows)
    |> put_in([:cols], cols)
  end

  # set the :snake_map index
  def put_snakes_in_map state do
    snake_map = Enum.reduce state["snakes"], %{}, fn snake, acc ->
      name = snake["name"]
      put_in acc[name], snake
    end

    state = put_in state[:snake_map], snake_map
  end

  def set_objects state do
    build_snake_map build_map state
  end

  def delete_map state do
    put_in state[:map], %{}
  end

  def put_food_in_map state do
    Enum.reduce state["food"], state, fn [x, y], state ->
      put_in state, path(x, y), Board.food
    end
  end

  def build_snake_map state do
    Enum.reduce state["snakes"], state, fn snake, state ->
      name = snake["name"]
      head_obj = %{"state" => "head", name => name}
      body_obj = %{"state" => "body", name => name}

      [[x, y] | body] = Enum.uniq snake["coords"]

      state = put_in state, path(x, y), head_obj

      Enum.reduce body, state, fn [x, y], state ->
        put_in state, path(x, y), body_obj
      end
    end
  end

  # sets the :map on the game
  def build_map state do
    put_snakes_in_map put_food_in_map delete_map state
  end

  def step(state) do
    state
    |> clean_up_dead
    |> grow_snakes
    |> remove_eaten_food
  end

  def update_board state do
    state = set_objects state
    max_y = state.rows - 1
    max_x = state.cols - 1

    board = for x <- 0..max_x do
      for y <- 0..max_y do
        case state[:map][x][y] do
          %{} = obj -> obj
          _ -> Board.empty
        end
      end
    end

    state = put_in state["board"], board
  end

  # wall collisions
  def dead?(%{rows: r, cols: c} = state, %{"coords" => [[x, y] |_]})
  when y in 0..(r - 1) and x in 0..(c - 1) do
    Enum.any? state["snakes"], fn %{"coords" => [_ | body]} ->
      Enum.member? body, [x, y]
    end
  end

  def dead?(_, _), do: true

  def clean_up_dead state do
    state = update_in state["snakes"], fn snakes ->
      snakes = Enum.reduce snakes, [], fn snake, snakes ->
        if dead?(state, snake) do
          snakes
        else
          [snake | snakes]
        end
      end

      Snake.head_to_head(snakes)
    end
  end

  def grow_snakes state do
    state = update_in state["snakes"], fn snakes ->
      for snake <- snakes do
        increase = grew(state, snake)
        Snake.grow(snake, increase)
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

  def apply_moves state, moves do
    update_in state["snakes"], fn snakes ->
      for snake <- snakes do
        name = snake["name"]
        direction = get_in moves, [name]

        move(snake, direction)
      end
    end
  end

  def move(snake, direction) do
    [dx, dy] = case direction do
      "up" -> up
      "down" -> down
      "left" -> left
      "right" -> right
    end

    body = snake["coords"]

    [x, y] = hd(body)

    tail = List.delete_at(body, -1)

    new_coords = [[dx + x, dy + y]] ++ tail

    put_in snake["coords"], new_coords
  end

  def board(state) do
    state["board"]
  end

  def path(x, y) do
    [
      Access.key(:map, %{}),
      Access.key(x, %{}),
      Access.key(y, %{}),
    ]
  end
end
