defmodule Snek.MoveControllerTest do
  use Snek.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  describe "POST index" do
    test "returns OK", %{conn: conn} do
      snakes = [
        Snek.Snake.new(%{}, 10, 10)
      ]

      board = [
        []
      ]

      parmas = Snek.World.new %{"snakes" => snakes, board: board}

      conn = post conn, move_path(conn, :index, parmas)
      assert json_response(conn, 200) == %{}
    end
  end
end
