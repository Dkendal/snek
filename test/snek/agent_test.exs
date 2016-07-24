defmodule Snek.AgentTest do
  use ExUnit.Case, async: true

  import Snek.Agent

  describe "#cartesian" do
    test "works with one set" do
      input = [
        [1, 2]
      ]

      assert cartesian(input) == [
        [1],
        [2],
      ]
    end

    test "works with two sets" do
      input = [
        [1, 2],
        [:a, :b],
      ]

      assert cartesian(input) == [
        [1, :a],
        [1, :b],
        [2, :a],
        [2, :b],
      ]
    end

    test "works with multiple lists" do
      input = [
        [1, 2],
        [:a, :b],
        [:c, :d],
      ]

      assert cartesian(input) == [
        [1, :a, :c],
        [1, :a, :d],
        [1, :b, :c],
        [1, :b, :d],
        [2, :a, :c],
        [2, :a, :d],
        [2, :b, :c],
        [2, :b, :d]
      ]
    end
  end
end
