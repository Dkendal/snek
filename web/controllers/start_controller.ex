defmodule Snek.StartController do
  use Snek.Web, :controller

  alias Snek.Start

  def index(conn, _params) do
    render(conn, "index.json", [])
  end
end
