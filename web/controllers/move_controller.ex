defmodule Snek.MoveController do
  alias Snek.{Agent}

  use Snek.Web, :controller

  def index(conn, params) do
    move = Agent.move(params, "Snek")

    render(conn, "index.json", move: move)
  end
end
