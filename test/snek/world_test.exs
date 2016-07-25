defmodule Snek.WorldTest do
  use ExUnit.Case, async: true

  import Snek.World

  describe "#set_dimensions" do
    test "sets the dim on the state", context do
      world = %{
        "board" => [
          [0, 0, 0],
          [0, 0, 0],
        ]
      }

      game = set_dimensions(world)

      assert game[:rows] == 2
      assert game[:cols] == 3
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
