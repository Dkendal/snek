defmodule Snek.Board do
  def new(width, height) do
    for _ <- 1..width do
      for _ <- 1..height do
        empty
      end
    end
  end

  def empty, do: %{"state" => "empty"}
end
