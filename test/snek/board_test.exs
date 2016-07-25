defmodule Snek.BoardTest do
  use ExUnit.Case, async: true

  import Snek.Board

  describe "#new" do
    test "creates a matrix" do
      assert(new(2, 2) == [
        [
          %{"state" => "empty"},
          %{"state" => "empty"},
        ],
        [
          %{"state" => "empty"},
          %{"state" => "empty"},
        ]
      ])
    end
  end
end
