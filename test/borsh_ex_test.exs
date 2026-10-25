defmodule BorshExTest do
  use ExUnit.Case
  alias BorshEx.{FakeData, FakeParent, FakeSubData}

  defmodule EdgeData do
    use BorshEx.Schema
    defstruct values: [], optional: nil, tail: 0

    borsh_schema do
      field :values, {"array", "boolean"}
      field :optional, {"option", "boolean"}
      field :tail, "u16"
    end
  end

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

  test "empty arrays and optional false round trip without consuming following fields" do
    object = %EdgeData{values: [], optional: false, tail: 2055}
    bytes = <<0, 0, 0, 0, 1, 0, 7, 8>>

    assert EdgeData.serialize(object) == bytes
    assert EdgeData.deserialize(bytes) == {:ok, object}
    assert EdgeData.deserialize(bytes <> <<9>>) == {:error, object, <<9>>}
  end

  test "zero-length fixed arrays consume no bytes" do
    assert encode([], {"array", {"u8", 0}}) == <<>>
    assert decode(<<7, 8>>, {"array", {"u8", 0}}) == {[], <<7, 8>>}
    assert decode(<<0, 0, 0, 0, 7, 8>>, {"array", "u8"}) == {[], <<7, 8>>}
  end

  test "fixed arrays enforce their declared length" do
    for values <- [[], [1], [1, 2, 3]] do
      assert_raise ArgumentError, fn -> encode(values, {"array", {"u8", 2}}) end
    end

    assert encode([1, 2], {"array", {"u8", 2}}) == <<1, 2>>
  end

  test "integer boundaries round trip and overflow is rejected" do
    for bits <- [8, 16, 32, 64], signed <- [false, true] do
      type = if signed, do: "i#{bits}", else: "u#{bits}"
      limit = Integer.pow(2, if(signed, do: bits - 1, else: bits))
      minimum = if signed, do: -limit, else: 0
      maximum = limit - 1

      for value <- [minimum, 0, maximum] do
        assert decode(encode(value, type), type) == {value, <<>>}
      end

      for value <- [minimum - 1, maximum + 1, 1.5, nil] do
        assert_raise ArgumentError, fn -> encode(value, type) end
      end
    end
  end

  test "integer encodings are little endian" do
    assert encode(258, "u16") == <<2, 1>>
    assert encode(-2, "i16") == <<254, 255>>
  end

  test "containers compose recursively" do
    cases = [
      {{"array", "boolean"}, [true, false]},
      {{"array", {"boolean", 2}}, [false, true]},
      {{"array", {"option", "boolean"}}, [nil, false, true]},
      {{"array", {"enum", [:first, :second]}}, [:second, :first]},
      {{"array", {"array", "u8"}}, [[], [1, 2]]},
      {{"array", {{"array", {"u8", 2}}, 2}}, [[1, 2], [3, 4]]},
      {{"array", {"array", {"u8", 2}}}, [[1, 2], [3, 4]]},
      {{"option", {"array", "boolean"}}, []},
      {{"option", {"array", "boolean"}}, [false, true]},
      {{"option", {"enum", [:first, :second]}}, :second}
    ]

    for {type, value} <- cases do
      assert decode(encode(value, type) <> <<99>>, type) == {value, <<99>>}
    end
  end

  test "nested vectors include each length prefix" do
    type = {"array", {"array", "u8"}}
    assert encode([[], [7]], type) == <<2, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 7>>
  end

  test "boolean and option tags are canonical" do
    assert encode(false, "boolean") == <<0>>
    assert encode(true, "boolean") == <<1>>
    assert encode(nil, {"option", "boolean"}) == <<0>>
    assert encode(false, {"option", "boolean"}) == <<1, 0>>

    for tag <- 2..255 do
      assert_raise ArgumentError, fn -> decode(<<tag>>, "boolean") end
      assert_raise ArgumentError, fn -> decode(<<tag>>, {"option", "boolean"}) end
    end

    for value <- [nil, 0, 1, "true"] do
      assert_raise ArgumentError, fn -> encode(value, "boolean") end
    end
  end

  test "strings require UTF-8 and use byte lengths" do
    value = <<195, 169>>
    assert encode(value, "string") == <<2, 0, 0, 0, 195, 169>>
    assert decode(encode(value, "string"), "string") == {value, <<>>}
    assert decode(encode("", "string"), "string") == {"", <<>>}
    assert_raise ArgumentError, fn -> encode(<<255>>, "string") end
    assert_raise ArgumentError, fn -> decode(<<1, 0, 0, 0, 255>>, "string") end
  end

  test "large arrays preserve order" do
    values = Enum.to_list(1..20_000)
    type = {"array", "u32"}
    assert decode(encode(values, type), type) == {values, <<>>}
  end

  test "invalid enum values and indexes are rejected" do
    type = {"enum", [:first, :second]}
    assert encode(:second, type) == <<1>>
    assert_raise ArgumentError, fn -> encode(:missing, type) end
    assert_raise ArgumentError, fn -> decode(<<2>>, type) end
    assert_raise ArgumentError, fn -> encode(256, {"enum", Enum.to_list(0..256)}) end
  end

  test "truncated values are rejected" do
    for {type, bytes} <- [
          {"u16", <<1>>},
          {"boolean", <<>>},
          {"string", <<1, 0, 0, 0>>},
          {{"option", "u8"}, <<1>>},
          {{"array", "u8"}, <<2, 0, 0, 0, 1>>}
        ] do
      assert_raise ArgumentError, fn -> decode(bytes, type) end
    end
  end

  defp encode(value, type) do
    BorshEx.Serializer.serialize_field({<<>>, value}, {:value, type})
  end

  defp decode(bytes, type) do
    {object, rest} = BorshEx.Deserializer.deserialize_field({%{}, bytes}, {:value, type})
    {object.value, rest}
  end
end
