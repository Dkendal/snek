defmodule Snek.Server do
  @size 20
  @max_food 1
  @valid_range 0..(@size - 1)
  @draw_frames 1
  @turn_delay 50
  @clear false

  import Snek.World

  def start do
    board = for x <- 0..@size, do: for y <- 0..@size, do: %{}

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

    state
    |> init_food(@max_food)
    |> update_board
    |> tick
  end

  def tick(%{"snakes" => []} = state, previous) do
    print previous
    IO.puts "Game Over"
    :ok
  end

  def tick(state), do: tick(state, state)

  def tick(state, previous) do
    if rem(state["turn"], @draw_frames) == 0 do
      print state
      Process.sleep @turn_delay
    end

    state
    |> update_in(["turn"], & &1 + 1)
    |> make_move
    |> step
    |> add_new_food
    |> update_board
    |> tick(state)
  end

  def init_food state, max do
    Enum.reduce 1..max, state, fn _, state ->
      update_in state["food"], fn food ->
        [rand_unoccupied_space(state) | food]
      end
    end
  end

  def make_move state do
    moves = for snake <- state["snakes"] do
      name = snake["name"]
      direction = Snek.Agent.move(state, name)
      {name, direction}
    end

    moves = Enum.into moves, %{}

    apply_moves state, moves
  end

  def add_new_food(state) do
    update_in state["food"], fn food ->
      new_food =
        for i <- 0..(@max_food - length(food)),
        i > 0,
        do: rand_unoccupied_space(state)

      food ++ new_food
    end
  end

  def replace_eaten_food state do
    state
    |> remove_eaten_food
    |> add_new_food
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

  def print(%{"board" => board, "food" => food, "snakes" => snakes} = state) do
    coords = Enum.flat_map snakes, & &1["coords"]

    max = @size
    min = -1
    range = min..max

    # clear
    if @clear, do: IO.write("\ec")

    for y <- range, x <- range do
      case {y, x} do
        {^min, ^min} ->
          " ╔"

        {^min, ^max} ->
          "╗ "

        {^max, ^min} ->
          " ╚"

        {^max, ^max} ->
          "╝ "

        {y, x} when y in [min, max] and not x in [min, max] ->
          "══"

        {_, ^min} ->
          " ║"

        {_, ^max} ->
          "║ "

        {y, x} ->
          board
          |> Enum.at(y)
          |> Enum.at(x)
          |> get_in(["state"])
          |> case do
            "head" ->
              "#{IO.ANSI.blue}[]#{IO.ANSI.reset}"
            "body" ->
              "#{IO.ANSI.green}[]#{IO.ANSI.reset}"
            "food" ->
              "#{IO.ANSI.red}()#{IO.ANSI.reset}"
            "empty" ->
              "  "
          end

      end |> IO.write

      if x == max do
        IO.write "\n"
      end
    end

    IO.puts "Turn: #{state["turn"]}"

    for snake <- state["snakes"] do
      IO.puts "#{snake["name"]}: #{length snake["coords"]}"
    end

    state
  end
end
