defmodule Snek.SnakeTest do
  use ExUnit.Case, async: true

  import Snek.Snake

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
