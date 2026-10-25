defmodule BorshEx.Serializer do
  @moduledoc false

  def serialize_field({acc, data}, {_, module}) when is_atom(module) do
    Enum.reduce(module.fields(), acc, fn {f, _} = field, acc ->
      data = Map.get(data, f)
      serialize_field({acc, data}, field)
    end)
  end

  def serialize_field({acc, data}, {_, {"option", type}}) do
    if is_nil(data) do
      acc <> <<0::8-little>>
    else
      acc = acc <> <<1::8-little>>
      serialize_field({acc, data}, {nil, type})
    end
  end

  def serialize_field({acc, data}, {_, {"array", {type, count}}})
      when is_integer(count) and count >= 0 do
    unless is_list(data) and length(data) == count do
      raise ArgumentError, "fixed array must contain exactly #{count} elements"
    end

    Enum.reduce(data, acc, fn element, acc ->
      serialize_field({acc, element}, {nil, type})
    end)
  end

  def serialize_field({acc, data}, {_, {"array", type}}) when is_list(data) do
    len = length(data)
    acc = serialize_field({acc, len}, {nil, "u32"})

    Enum.reduce(data, acc, fn element, acc ->
      serialize_field({acc, element}, {nil, type})
    end)
  end

  def serialize_field({acc, data}, {_, {"enum", values}}) when is_list(values) do
    idx = Enum.find_index(values, &(&1 === data))

    unless length(values) in 1..256 and is_integer(idx) do
      raise ArgumentError, "invalid enum value or variant count"
    end

    acc <> <<idx::8-little>>
  end

  def serialize_field({acc, data}, {_, "boolean"}) when is_boolean(data) do
    value = if data, do: 1, else: 0
    acc <> <<value::8-little>>
  end

  def serialize_field({acc, data}, {_, "u" <> len}) do
    len = String.to_integer(len)

    unless len in [8, 16, 32, 64] and is_integer(data) and data >= 0 and
             data < :erlang.bsl(1, len) do
      raise ArgumentError, "value is outside the u#{len} integer range"
    end

    acc <> <<data::size(len)-little>>
  end

  def serialize_field({acc, data}, {_, "i" <> len}) do
    len = String.to_integer(len)

    unless len in [8, 16, 32, 64] and is_integer(data) and
             data >= -:erlang.bsl(1, len - 1) and data < :erlang.bsl(1, len - 1) do
      raise ArgumentError, "value is outside the i#{len} integer range"
    end

    acc <> <<data::signed-size(len)-little>>
  end

  def serialize_field({acc, data}, {_, "string"}) when is_binary(data) do
    unless String.valid?(data) do
      raise ArgumentError, "string must contain valid UTF-8"
    end

    len = byte_size(data)
    serialize_field({acc, len}, {nil, "u32"}) <> data
  end

  def serialize_field({_acc, _data}, {_, type}) do
    raise ArgumentError, "invalid Borsh value or unsupported type #{inspect(type)}"
  end
end
