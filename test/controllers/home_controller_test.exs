defmodule Snek.HomeControllerTest do
  use Snek.ConnCase

  alias Snek.Home

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  describe "GET index" do
    test "returns OK", %{conn: conn} do
      conn = get conn, home_path(conn, :index)
      assert %{"color" => _, "head" => _} = json_response(conn, 200)
    end
  end
end
