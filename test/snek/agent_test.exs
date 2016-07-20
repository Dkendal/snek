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

  describe ".utility" do
    test "locations closer to food are better", context do
      assert(
        Snek.Agent.utility(context.state, [3, 0]) <
        Snek.Agent.utility(context.state, [2, 0]))
    end
  end

  describe "#head" do
    test "returns the position of the head", context do
      assert Snek.Agent.head(context.state) == [3, 0]
    end
  end
end
