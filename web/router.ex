defmodule Snek.Router do
  use Snek.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Snek do
    pipe_through :api
  end
end
