defmodule Snek.EndView do
  use Snek.Web, :view

  def render("index.json", _params) do
    %{}
  end
end
