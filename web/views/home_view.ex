defmodule Snek.HomeView do
  use Snek.Web, :view

  def render("index.json", _params) do
    %{
      color: "#6699ff",
      head: "",
    }
  end
end
