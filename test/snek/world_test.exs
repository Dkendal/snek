defmodule Snek.WorldTest do
  use ExUnit.Case, async: true

  import Snek.World

  setup do
    board = for _ <- 1..20, do: for _ <- 1..10, do: 0

    game = Snek.World.new(
      %{
        "board" => board
      }
    )

    %{game: game}
  end

  describe "#set_dimensions" do
    test "sets the dim on the state", context do
      game = Snek.World.set_dimensions(context.game)

      assert game[:rows] == 20
      assert game[:cols] == 10
    end
  end

  describe "#head_to_head" do
    test "ties result in participants all dying" do
      snakes = [
        %{"name" => "a", "coords" => [[0,0]]},
        %{"name" => "b", "coords" => [[0,0]]},
        %{"name" => "b", "coords" => [[0,0]]},
      ]

      assert head_to_head(snakes) == []
    end

    test "kills off the smaller snake and grows the victor" do
      snakes = [
        %{"name" => "a", "coords" => [[0,0], [0,1], [0,2]]},
        %{"name" => "b", "coords" => [[0,0], [1,0]]},
      ]

      assert head_to_head(snakes) == [
        %{"name" => "a", "coords" => [[0,0], [0, 1], [0,2], [0,2]]}
      ]
    end
  end
end
