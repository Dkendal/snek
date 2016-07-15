defmodule Snek.StartControllerTest do
  use Snek.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "post index" do
    test "returns OK", %{conn: conn} do
      conn = post conn, start_path(conn, :index, [])
      assert json_response(conn, 200) == %{}
    end
  end
end
