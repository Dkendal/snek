defmodule Snek.Server do
  def start do
    size = 10
    board = for x <- 1..size, do: for y <- 1..size, do: 0
    print board
  end

  def print(board) do
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

        {_, _} ->
          board
          |> Enum.at(y)
          |> Enum.at(x)
          |> case do
            0 -> " "
            x -> x
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
