defmodule BorshExTest do
  use ExUnit.Case
  alias BorshEx.{FakeData, FakeParent, FakeSubData}

  @bitstring <<255, 20, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 49, 50, 51>>

  test "simple case" do
    {:ok, result} = FakeData.deserialize(@bitstring)
    assert result == %BorshEx.FakeData{a: 255, b: 20, c: "123"}
    assert BorshEx.FakeData.serialize(result) == @bitstring
  end

  @bitstring <<3, 0, 0, 0, 51, 52, 53, 255, 20, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 49, 50, 51>>
  test "nested struct" do
    {:ok, result} = FakeParent.deserialize(@bitstring)
    assert result == %BorshEx.FakeParent{b: %BorshEx.FakeData{a: 255, b: 20, c: "123"}, l: "345"}
    assert BorshEx.FakeParent.serialize(result) == @bitstring
  end

  test "all types" do
    object = %FakeSubData{
      a: "Hello",
      b: 109,
      c: 65,
      d: [1, 2, 3],
      e: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      f: true,
      g: false,
      h: nil,
      i: "Coucou",
      j: ["a", "b", "c"],
      k: -10
    }

    assert bitstring = FakeSubData.serialize(object)
    {:ok, result} = FakeSubData.deserialize(bitstring)
    assert result == object
  end

  test "metadata" do
    assert {:ok, result} = BorshEx.Metadata.deserialize(BorshEx.Metadata.bitstring())
    assert result == BorshEx.Metadata.example()
    assert BorshEx.Metadata.serialize(result) == BorshEx.Metadata.bitstring()
  end
end
