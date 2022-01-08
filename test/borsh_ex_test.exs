defmodule BorshExTest do
  use ExUnit.Case
  doctest BorshEx

  test "greets the world" do
    assert BorshEx.hello() == :world
  end
end
