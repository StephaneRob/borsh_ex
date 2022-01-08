defmodule BorshEx.Deserializer do
  def deserialize_field({acc, bitstring}, {nil, module}) when is_atom(module) do
    Enum.reduce(module.fields(), {acc, bitstring}, fn field, acc ->
      deserialize_field(acc, field)
    end)
  end

  def deserialize_field({acc, bitstring}, {field, module}) when is_atom(module) do
    {result, rest} = read_value(bitstring, module)
    {Map.put(acc, field, result), rest}
  end

  def deserialize_field({acc, bitstring}, {field, {"array", {type, count}}}) do
    {values, rest} =
      Enum.reduce(1..count, {[], bitstring}, fn _, {acc, bitstring} ->
        {value, rest} = read_value(bitstring, type)

        {acc ++ [value], rest}
      end)

    {Map.put(acc, field, values), rest}
  end

  def deserialize_field({acc, <<option::unsigned-8-little>> <> rest}, {field, {"option", type}}) do
    if option == 1 do
      deserialize_field({acc, rest}, {field, type})
    else
      {Map.put(acc, field, nil), rest}
    end
  end

  def deserialize_field({acc, bitstring}, {field, {"array", type}}) do
    <<len::32-little>> <> rest = bitstring

    {values, rest} =
      Enum.reduce(1..len, {[], rest}, fn _, {acc, bitstring} ->
        {value, rest} = read_value(bitstring, type)
        {acc ++ [value], rest}
      end)

    {Map.put(acc, field, values), rest}
  end

  def deserialize_field({acc, <<idx::8-little>> <> rest}, {field, {"enum", values}}) do
    if idx >= length(values) do
      raise "Enum #{field} index: ${idx} is out of range"
    end

    {Map.put(acc, field, Enum.at(values, idx)), rest}
  end

  def deserialize_field({acc, <<x::unsigned-8-little>> <> rest}, {field, "boolean"}) do
    {Map.put(acc, field, x == 1), rest}
  end

  [
    {"u8", 8},
    {"u16", 16},
    {"u32", 32},
    {"u64", 64},
    {"i8", 8},
    {"i16", 16},
    {"i32", 32},
    {"i64", 64}
  ]
  |> Enum.each(fn {type, _} ->
    def deserialize_field({acc, bitstring}, {field, unquote(type)}) do
      {value, rest} = read_value(bitstring, unquote(type))
      {Map.put(acc, field, value), rest}
    end
  end)

  def deserialize_field({acc, bitstring}, {field, "string"}) do
    {value, rest} = read_value(bitstring, "string")
    {Map.put(acc, field, value), rest}
  end

  def read_value(bitstring, module) when is_atom(module) do
    new_accumulator = struct(module)

    Enum.reduce(module.fields(), {new_accumulator, bitstring}, fn field, acc ->
      deserialize_field(acc, field)
    end)
  end

  def read_value(<<len::32-little>> <> rest, "string") do
    <<string::binary-size(len)>> <> rest = rest
    {string, rest}
  end

  [{"u8", 8}, {"u16", 16}, {"u32", 32}, {"u64", 64}]
  |> Enum.each(fn {type, len} ->
    def read_value(<<value::size(unquote(len))-little>> <> rest, unquote(type)) do
      {value, rest}
    end
  end)

  [{"i8", 8}, {"i16", 16}, {"i32", 32}, {"i64", 64}]
  |> Enum.each(fn {type, len} ->
    def read_value(<<value::signed-size(unquote(len))-little>> <> rest, unquote(type)) do
      {value, rest}
    end
  end)
end
