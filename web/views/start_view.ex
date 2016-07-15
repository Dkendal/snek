defmodule Snek.StartView do
  use Snek.Web, :view

  def render("index.json", _params) do
    %{
      name: "Snek",
      color: "#6699ff",
      head_url: "",
      taunt: "gotta go fast"
    }
  end
end
