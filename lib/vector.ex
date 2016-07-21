defmodule Vector do
  def sub(a, b) when length(a) == length(b) do
    Stream.zip(a, b)
    |> Enum.map(fn {x, y} ->
      x - y
    end)
  end

  def add(a, b) when length(a) == length(b) do
    Stream.zip(a, b)
    |> Enum.map(fn {x, y} ->
      x + y
    end)
  end

  def magnitude(a) do
    Stream.map(a, & :math.pow(&1, 2))
    |> Enum.sum()
    |> :math.sqrt()
  end

  def distance(a, b) do
    magnitude(sub(a, b))
  end
end
