defmodule Snek.Server do
  @size 20

  def start do
    board = for x <- 0..@size, do: for y <- 0..@size, do: 0

    snakes = [
      %{
        "color" => "#6699ff",
        "coords" => [[4, 4], [4, 4], [4, 4]],
        "head_url" => "",
        "name" => "Snek",
        "taunt" => "gotta go fast",
        "url" => "http://localhost:4000"
      }
    ]

    state = %{
      "game_id" => "",
      "turn" => 0,
      "board" => board,
      "snakes" => snakes,
      "food" => []
    }

    state = init_food state, 4

    tick state
  end

  def tick(%{"snakes" => []} = state) do
    print state
    IO.puts "Game Over"
    :ok
  end

  def tick(state) do
    print state

    Process.sleep 500

    state
    |> make_move
    |> bring_out_your_dead
    |> grow_snakes
    |> replace_eaten_food
    |> tick
  end

  def init_food state, max do
    Enum.reduce 1..max, state, fn _, state ->
      update_in state["food"], fn food ->
        [rand_unoccupied_space(state) | food]
      end
    end
  end

  def make_move state do
    state = update_in state["snakes"], fn snakes ->
      for snake <- snakes, do: move(snake, Snek.Agent.move(state))
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

  def replace_eaten_food state do
    state = update_in state["food"], fn food ->
      Enum.reduce food, [], fn apple, food ->
        if eaten?(state, apple) do
          [rand_unoccupied_space(state) | food]
        else
          [apple | food]
        end
      end
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

  def rand_unoccupied_space(state) do
    snakes = Enum.flat_map state["snakes"], & &1["coords"]
    food = state["food"]
    rand_unoccupied_space(snakes, food)
  end

  def rand_unoccupied_space(snakes, food) do
    x = :random.uniform(@size) - 1
    y = :random.uniform(@size) - 1

    new_pos = [y, x]

    if not new_pos in snakes and not new_pos in food do
      new_pos
    else
      rand_unoccupied_space(snakes, food)
    end
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

  def grew(state, snake) do
    head = hd snake["coords"]

    if Enum.member? state["food"], head do
      1
    else
      0
    end
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

  def print(%{"board" => board, "food" => food, "snakes" => snakes}) do
    coords = Enum.flat_map snakes, & &1["coords"]

    # Enum.reduce(coords, %{}, fn [y, x], acc ->
    #   put_in(acc, [Access.key(y, %{}), x], "snake")
    # end)

    max = Enum.count board
    min = -1
    range = min..max

    # clear
    IO.write("\ec")

    for y <- range, x <- range do
      case {y, x} do
        {^min, ^min} ->
          "╔═"

        {^min, ^max} ->
          "╗ "

        {^max, ^min} ->
          "╚═"

        {^max, ^max} ->
          "╝ "

        {y, x} when y in [min, max] and not x in [min, max] ->
          "══"

        {y, x} when x in [min, max] and not y in [min, max] ->
          "║ "

        {y, x} ->
          cond do
            Enum.member?(food, [y, x]) ->
              "()"
            Enum.member?(coords, [y, x]) ->
              "[]"
            true ->
              "  "
          end
      end |> IO.write

      if x == max do
        IO.write "\n"
      end
    end

    :ok
  end
end
