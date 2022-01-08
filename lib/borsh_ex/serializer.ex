defmodule BorshEx.Serializer do
  def serialize_field({acc, data}, {_, module}) when is_atom(module) do
    Enum.reduce(module.fields(), acc, fn {f, _} = field, acc ->
      data = Map.get(data, f)
      serialize_field({acc, data}, field)
    end)
  end

  def serialize_field({acc, data}, {_, {"option", type}}) do
    if data do
      acc = acc <> <<1::8-little>>
      serialize_field({acc, data}, {nil, type})
    else
      acc <> <<0::8-little>>
    end
  end

  def serialize_field({acc, data}, {_, {"array", {type, _count}}}) do
    Enum.reduce(data, acc, fn element, acc ->
      serialize_field({acc, element}, {nil, type})
    end)
  end

  def serialize_field({acc, data}, {_, {"array", type}}) do
    len = length(data)
    acc = acc <> <<len::32-little>>

    Enum.reduce(data, acc, fn element, acc ->
      serialize_field({acc, element}, {nil, type})
    end)
  end

  def serialize_field({acc, data}, {_, {"enum", values}}) do
    idx = Enum.find_index(values, &(&1 == data))
    acc <> <<idx::8-little>>
  end

  def serialize_field({acc, data}, {_, "boolean"}) do
    value = if data, do: 1, else: 0
    acc <> <<value::8-little>>
  end

  def serialize_field({acc, data}, {_, "u" <> len}) do
    len = String.to_integer(len)
    acc <> <<data::size(len)-little>>
  end

  def serialize_field({acc, data}, {_, "i" <> len}) do
    len = String.to_integer(len)
    acc <> <<data::signed-size(len)-little>>
  end

  def serialize_field({acc, data}, {_, "string"}) do
    len = byte_size(data)
    acc <> <<len::32-little>> <> data
  end
end
