defmodule Snek.HomeController do
  use Snek.Web, :controller

  alias Snek.Home

  def index(conn, _params) do
    render(conn, "index.json", [])
  end
end
