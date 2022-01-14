defmodule BorshEx do
  @moduledoc """
  Elixir implementation of Binary Object Representation Serializer for Hashing ([borsh](borsh.io))

  ## Usage

  Define schema using `BorshEx.Schema`
      defmodule SubData do
        use BorshEx.Schema
        defstruct address: nil

        borsh_schema do
          field :address, "string"
        end
      end

      defmodule Data do
        use BorshEx.Schema
        defstruct name: nil

        borsh_schema do
          field :id, "u16"
          field :sub_data, SubData
        end
      end

  Once schema is define, we are able to serialize a struct into a binary or deserialize to a struct.

      iex> data = %Data{id: 45, sub_data: %SubData{address: "Hello world!"}}
      %Data{id: 45, sub_data: %SubData{address: "Hello world!"}}

      iex> bistring = Data.serialize(data)
      <<45, 0, 12, 0, 0, 0, 72, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 33>>

      iex> data = Data.deserialize(bitstring)
      {:ok, %Data{id: 45, sub_data: %SubData{address: "Hello world!"}}}

  In some case the bitstring is longer than necessary, some bytes are not used

      iex> bitstring = <<45, 0, 12, 0, 0, 0, 72, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 33, 5, 0>>
      <<45, 0, 12, 0, 0, 0, 72, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 33, 10, 5, 0>>

      iex> data = Data.deserialize(bitstring)
      {:error, %Data{id: 45, sub_data: %SubData{address: "Hello world!"}}, <<5, 0>>}

  `<<5, 0>>` returned are unused bytes.

  ## Basic types

  | type                      | example               |
  | ------------------------- | --------------------- |
  | `u8`, `u16`, `u32`, `u64` | `field :id, "u8"`     |
  | `i8`, `i16`, `i32`, `i64` | `field :id, "i8"`     |
  | `boolean`                 | `field :id, "bool"`   |
  | `string`                  | `field :id, "string"` |
  | `struct`                  | `field :id, MyStruct` |

  ## Complex types

  All types can be used in a more complex one

  ### Array

  An array can have a fixed size

      # ids is a list of 32 `u16` values
      # sub_data is a list of 32 Subdata strut
      borsh_schema do
        field :ids, {"array", {"u16", 32}}
        field :sub_data, {"array", {Subdata, 32}}
      end

  Or variable length

      # ids is a list `u16` value
      # sub_data is a list of Subdata strut
      borsh_schema do
        field :ids, {"array", "u16"}
        field :sub_data, {"array", {Subdata, 32}}
      end

  ### Option

  a field can be optional

      # if name can be nil or a string
      borsh_schema do
        field :name, {"option", "string"}
      end

      iex> data = %Data{name: nil}
      %Data{name: nil}

      iex> Data.serialize(data)
      <<0>>

      iex> data = %Data{name: "Hello"}
      %Data{name: "Hello"}

      iex> Data.serialize(data)
      <<1, 5, 0, 0, 0, 72, 101, 108, 108, 111>>
  """
end
