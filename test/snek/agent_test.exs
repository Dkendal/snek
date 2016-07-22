defmodule Snek.AgentTest do
  use ExUnit.Case, async: true

  setup do
    snakes = [
      %{
        "coords" => [[3, 0]],
        "name" => "Snek",
      }
    ]

    food = [[0,0]]

    state = Snek.World.new %{"snakes" => snakes, "food" => food}

    state = Snek.World.update_board(state)

    %{state: state}
  end
end
