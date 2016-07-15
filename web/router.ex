defmodule Snek.Router do
  use Snek.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Snek do
    pipe_through :api
  end

  get "/", Snek.HomeController, :index

  post "/start", Snek.StartController, :index

  post "/end", Snek.EndController, :index

  post "/move", Snek.MoveController, :index
end
