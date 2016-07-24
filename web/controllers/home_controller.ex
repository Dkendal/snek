defmodule Snek.HomeController do
  use Snek.Web, :controller

  def index(conn, _params) do
    render(conn, "index.json", [])
  end
end
