defmodule Snek.EndController do
  use Snek.Web, :controller

  alias Snek.End

  def index(conn, _params) do
    render(conn, "index.json", [])
  end
end
