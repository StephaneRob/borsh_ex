defmodule BorshEx.SchemaTest do
  use ExUnit.Case

  alias BorshEx.FakeData

  test "schema must expose fields / serialize / deserialize functions" do
    assert functions = FakeData.__info__(:functions)
    assert Enum.find(functions, &(&1 == {:fields, 0}))
    assert Enum.find(functions, &(&1 == {:deserialize, 1}))
    assert Enum.find(functions, &(&1 == {:serialize, 1}))
  end

  test "fields must return borsh schema" do
    assert fields = FakeData.fields()
    assert fields == [{:a, "u8"}, {:b, "u64"}, {:c, "string"}]
  end
end
