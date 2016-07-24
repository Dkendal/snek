defmodule Snek.MoveView do
  use Snek.Web, :view

  def render("index.json", %{move: move}) do
    %{
      move: move,
      taunt: move
    }
  end
end
