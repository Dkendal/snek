defmodule Snek.Server do
  def start do
    size = 10
    board = for x <- 1..size, do: for y <- 1..size, do: 0

    #food = for _ <- 1..4, do: [:random.uniform(size), :random.uniform(size)]
    food = [[1, 4], [3, 0], [5, 2]]

    snakes = [%{
      "color" => "#6699ff",
      "coords" => [[4, 4], [4, 4], [4, 4]],
      "head_url" => "",
      "name" => "Snek",
      "taunt" => "gotta go fast",
      "url" => "http://localhost:4000"
    }]

    state = %{
      "game_id" => "",
      "turn" => 0,
      "board" => board,
      "snakes" => snakes,
      "food" => food
    }

    turn state, 10
  end

  def turn(_state, 0) do
    :ok
  end

  def turn(state, tick) do
    Process.sleep 500
    print state

    snakes = Enum.map state["snakes"], fn snake ->
      move(snake, Snek.Agent.move(state))
    end

    state = put_in state["snakes"], snakes

    turn(state, tick - 1)
  end

  def move(snake, direction) do
    [dy, dx] = case direction do
      "up" ->
        [1, 0]
      "down" ->
        [-1, 0]
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

    max = Enum.count board
    min = -1
    range = min..max

    # clear
    IO.write("\ec")

    for y <- range, x <- range do
      case {y, x} do
        {^min, ^min} ->
          "╔"

        {^min, ^max} ->
          "╗"

        {^max, ^min} ->
          "╚"

        {^max, ^max} ->
          "╝"

        {y, x} when y in [min, max] and not x in [min, max] ->
          "═"

        {y, x} when x in [min, max] and not y in [min, max] ->
          "║"

        {y, x} ->
          cond do
            Enum.member?(food, [y, x]) ->
              "F"
            Enum.member?(coords, [y, x]) ->
              "X"
            true ->
              " "
          end
      end
      |> IO.write

      if x == max do
        IO.write "\n"
      end
    end

    :ok
  end
end
