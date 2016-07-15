defmodule Snek.EndControllerTest do
  use Snek.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST index" do
    test "returns OK", %{conn: conn} do
      conn = post conn, end_path(conn, :index, [])
      assert json_response(conn, 200) == %{}
    end
  end
end
