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
end
