defmodule FloodFillTest do
  alias Snek.{Local}

  use ExUnit.Case, async: true

  import FloodFill

  describe "#flood_fill_count" do
    setup [:cut_board, :walled]

    test "reports the number of free spaces", context do
      assert flood_fill_count(context.cut_board) == 6
    end

    test "reports the number of free spaces when walled in", context do
      assert flood_fill_count(context.walled) == 2
    end
  end

  def walled(context) do
    snake = %{
      "coords" => [
        [2,0],
        [2,1],
        [1,1],
        [0,1],
      ],
    }

    world = %{
      map: %{
        2 => %{0 => %{"state" => "head", "snake" => "test"}},
        2 => %{1 => %{"state" => "body", "snake" => "test"}},
        1 => %{1 => %{"state" => "body", "snake" => "test"}},
        0 => %{1 => %{"state" => "body", "snake" => "test"}},
      },
      snake_map: %{
        "test" => snake
      },
      rows: 3,
      cols: 3,
    }

    # +------+
    # |  []  |
    # |  []  |
    # |{}[]  |
    # +------+

    local = %Local{name: "test", world: world}

    Map.put context, :walled, local
  end
  def cut_board(context) do
    snake = %{
      "coords" => [
        [2,1],
        [1,1],
        [0,1],
      ],
    }

    world = %{
      map: %{
        2 => %{1 => %{"state" => "head", "snake" => "test"}},
        1 => %{1 => %{"state" => "body", "snake" => "test"}},
        0 => %{1 => %{"state" => "body", "snake" => "test"}},
      },
      snake_map: %{
        "test" => snake
      },
      rows: 3,
      cols: 3,
    }

    # +------+
    # |  []  |
    # |  []  |
    # |  {}  |
    # +------+

    local = %Local{name: "test", world: world}

    Map.put context, :cut_board, local
  end
end
