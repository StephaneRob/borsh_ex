defmodule BorshEx.Schema do
  defmacro __using__(_) do
    quote do
      import BorshEx.Schema, only: [borsh_schema: 1, field: 2]

      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def fields do
        Enum.reverse(@fields)
      end

      def deserialize(bitstring) do
        {object, rest} =
          BorshEx.Deserializer.deserialize_field(
            {struct(__MODULE__), bitstring},
            {nil, __MODULE__}
          )

        if byte_size(rest) == 0 do
          {:ok, object}
        else
          {:error, object, rest}
        end
      end

      def serialize(object) do
        BorshEx.Serializer.serialize_field({<<>>, object}, {nil, __MODULE__})
      end
    end
  end

  defmacro borsh_schema(do: block) do
    quote do
      unquote(block)
    end
  end

  defmacro field(name, type) do
    quote do
      Module.put_attribute(__MODULE__, :fields, {unquote(name), unquote(type)})
    end
  end
end
