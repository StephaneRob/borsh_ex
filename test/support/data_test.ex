defmodule BorshEx.DataTest do
  use BorshEx.Schema

  defstruct x: nil, y: nil, z: nil

  schema do
    field :x, "u8"
    field :y, "u64"
    field :z, "string"
  end
end
