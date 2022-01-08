defmodule BorshEx.SchemaTest do
  use ExUnit.Case

  alias BorshEx.DataTest

  test "schema must expose fields / serialize / deserialize functions" do
    assert functions = DataTest.__info__(:functions)
    assert Enum.find(functions, &(&1 == {:fields, 0}))
    assert Enum.find(functions, &(&1 == {:deserialize, 1}))
    assert Enum.find(functions, &(&1 == {:serialize, 1}))
  end

  test "fields must return borsh schema" do
    assert fields = DataTest.fields()
    assert fields == [{:x, "u8"}, {:y, "u64"}, {:z, "string"}]
  end
end
