defmodule VectorTest do
  alias Vector, as: V

  use ExUnit.Case, async: true

  describe "#sub" do
    test "subtracts vectors" do
      assert V.sub([1,2], [3,4]) == [-2, -2]
    end
  end

  describe "#add" do
    test "adds vectors" do
      assert V.add([1,2], [3,4]) == [4, 6]
    end
  end

  describe "#magnitude" do
    test "returns the pythagorean distance" do
      assert V.magnitude([3, 4]) == 5
    end
  end

  describe "#distance" do
    test "returns the euclidean distance between the two vectors" do
      assert V.distance([0, 0], [3, 0]) == 3
    end
  end
end
