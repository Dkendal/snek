defmodule Snek.WorldTest do
  use ExUnit.Case, async: true

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
end
