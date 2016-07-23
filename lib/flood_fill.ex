defmodule FloodFill do
  alias Snek.{World}

  def flood_fill_count(coords: [], world: _) do
    0
  end

  def flood_fill_count(coords: nil, world: _) do
    0
  end

  # Flood-fill (node, target-color, replacement-color):
  #  1. If target-color is equal to replacement-color, return.
  #  2. Set Q to the empty queue.
  #  3. Add node to the end of Q.
  #  4. While Q is not empty:
  #  5.     Set n equal to the first element of Q.
  #  6.     Remove first element from Q.
  #  7.     If the color of n is equal to target-color:
  #  8.         Set the color of n to replacement-color and mark "n" as processed.
  #  9.         Add west node to end of Q if west has not been processed yet.
  #  10.        Add east node to end of Q if east has not been processed yet.
  #  11.        Add north node to end of Q if north has not been processed yet.
  #  12.        Add south node to end of Q if south has not been processed yet.
  #  13. Return.
  def flood_fill_count(coords: coords, world: world) do
    start = hd coords
    dim = {world.rows, world.cols}
    queue = :queue.new

    processed = MapSet.new

    neighbours = neighbour_fn(dim)
    state = state_fn(world)

    n = neighbours.(start, processed)

    queue = Enum.reduce n, queue, fn x, s ->
      :queue.in x, s
    end

    f = {neighbours, state}

    ff queue, processed, f, 0
  end

  def flood_fill_count(local) do
    coords = Snek.Agent.Local.this(local)["coords"]

    flood_fill_count coords: coords, world: local.world
  end

  def ff {:empty, _}, processed, _, count do
    count
  end

  def ff {{:value, value}, queue}, processed, {_, state} = f, n do
    ff {{:state, state.(value), value}, queue}, processed, f, n
  end

  def ff {{:state, :empty, current}, queue}, processed, {neighbours, _} = f, count do
    processed = MapSet.put processed, current

    n = neighbours.(current, processed)

    {queue, processed} = Enum.reduce n, {queue, processed}, fn x, {q, p} ->
      q = :queue.in x, q
      p = MapSet.put p, x
      {q, p}
    end

    ff queue, processed, f, count + 1
  end

  def ff {{:state, :occupied, _}, queue}, processed, f, n do
    ff :queue.out(queue), processed, f, n
  end

  def ff queue, processed, f, n do
    ff :queue.out(queue), processed, f, n
  end

  def state_fn(world) do
    fn ([y, x])->
      case world.map[y][x] do
        nil ->
          :empty

        %{"state" => "empty"} ->
          :empty

        %{"state" => "food"} ->
          :empty

        _ ->
          :occupied
      end
    end
  end

  def neighbour_fn({max_y, max_x}) do
    moves = World.moves

    fn current, processed ->
      neighbours = Stream.map(moves, & Vector.add(&1, current))

      neighbours = Stream.reject neighbours, fn
        [y, x] when y in [-1, max_y] or x in [-1, max_x] ->
          true
        pos ->
          MapSet.member?(processed, pos)
      end
    end
  end
end
