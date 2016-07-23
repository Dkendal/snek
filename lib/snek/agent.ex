defmodule Snek.Agent do
  alias Snek.{World}
  alias Vector, as: V

  @directions ~W(up down left right)


  # local representation of a world state, with the name of the snake enocoded
  defmodule Local do
    defstruct [
      :name, # name of this snake
      :world, # game state
      moves: [],
      utility: %{}
    ]

    def score local do
      get_in(local.utility, [Access.key(local.name, 0.0)])
    end

    @dead %{
      "coords" => []
    }

    # returns this snake
    def this local do
      local.world.snake_map[local.name] || @dead
    end

    def heuristic local do
      free_space = flood_fill_count(local)
      len = length(this(local)["coords"]) || 0

      Enum.min [free_space, len]
    end

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
      coords = this(local)["coords"]

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
        neighbours = Stream.map(moves, & V.add(&1, current))

        neighbours = Stream.reject neighbours, fn
          [y, x] when y in [-1, max_y] or x in [-1, max_x] ->
            true
          pos ->
            MapSet.member?(processed, pos)
        end
      end
    end
  end

   def move(state, name) do
     state = World.set_dimensions state
     state = put_in state["board"], nil
     move %Local{
       name: name,
       world: state,
     }
   end

   defp move(local) do
     locals = search(local, 2)

     local = Enum.max_by locals, fn local ->
       Local.score(local) + Local.heuristic(local)
     end

     IO.inspect Float.round(Local.score(local), 2)
     IO.inspect Local.heuristic(local)

     List.last local.moves
   end

   def search(local, 0) do
     [local]
   end

   def search(local, depth) do
     Enum.flat_map @directions, fn dir ->
       local = update_in local.moves, fn moves ->
         [dir | moves]
       end

       local = update_in local.world, fn state ->
         state
         |> World.apply_moves(%{local.name => dir})
         |> World.step()
         |> World.set_objects()
       end

       snakes = local.world["snakes"]
       world = local.world

       utility = Enum.reduce snakes, %{}, fn snake, acc ->
         name = snake["name"]

         val = utility(world, snake)

         put_in acc[name], val
       end

       local = put_in(local.utility, utility)

       if Local.score(local) <= 0 do
         # don't expand nodes that result in death
         [local]
       else
         search(local, depth - 1)
       end
     end
   end

   def utility(state, snake) do
     len = length(snake["coords"])
     dist = distance_from_food(state, snake)

     d = if dist == 0, do: 1, else: 1 / dist
     0.0 + d + len
   end

  def distance_from_food(state, snake) do
     head = hd snake["coords"]
     food = state["food"]

     distance_from_food(head: head, food: food)
   end

   def distance_from_food(head: _, food: []) do
     0
   end

   def distance_from_food(head: head, food: food) do
      Enum.min Stream.map(food, fn apple ->
       V.distance(apple, head)
     end)
   end
end
