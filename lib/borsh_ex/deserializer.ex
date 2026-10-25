defmodule BorshEx.Deserializer do
  @moduledoc false

  def deserialize_field({acc, bitstring}, {nil, module}) when is_atom(module) do
    Enum.reduce(module.fields(), {acc, bitstring}, fn field, acc ->
      deserialize_field(acc, field)
    end)
  end

  def deserialize_field({acc, bitstring}, {field, type}) do
    {result, rest} = read_value(bitstring, type)
    {Map.put(acc, field, result), rest}
  end

  def read_value(bitstring, module) when is_atom(module) do
    new_accumulator = struct(module)

    Enum.reduce(module.fields(), {new_accumulator, bitstring}, fn field, acc ->
      deserialize_field(acc, field)
    end)
  end

  def read_value(bitstring, {"array", {type, count}})
      when is_integer(count) and count >= 0 do
    read_array(bitstring, type, count, [])
  end

  def read_value(<<count::32-little, rest::binary>>, {"array", type}) do
    read_array(rest, type, count, [])
  end

  def read_value(<<0, rest::binary>>, {"option", _type}), do: {nil, rest}
  def read_value(<<1, rest::binary>>, {"option", type}), do: read_value(rest, type)

  def read_value(<<index, rest::binary>>, {"enum", values}) when is_list(values) do
    count = length(values)

    unless count in 1..256 and index < count do
      raise ArgumentError, "invalid enum index or variant count"
    end

    {Enum.at(values, index), rest}
  end

  def read_value(<<0, rest::binary>>, "boolean"), do: {false, rest}
  def read_value(<<1, rest::binary>>, "boolean"), do: {true, rest}

  def read_value(<<len::32-little, string::binary-size(len), rest::binary>>, "string") do
    unless String.valid?(string) do
      raise ArgumentError, "string must contain valid UTF-8"
    end

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

  def read_value(_bitstring, type) do
    raise ArgumentError, "invalid or truncated Borsh value for #{inspect(type)}"
  end

  defp read_array(rest, _type, 0, values), do: {Enum.reverse(values), rest}

  defp read_array(bitstring, type, count, values) do
    {value, rest} = read_value(bitstring, type)
    read_array(rest, type, count - 1, [value | values])
  end
end
