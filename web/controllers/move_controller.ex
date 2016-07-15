defmodule Snek.MoveController do
  use Snek.Web, :controller

  alias Snek.Move

  def index(conn, _params) do
    render(conn, "index.json", [])
  end
end
