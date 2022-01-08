defmodule BorshEx.FakeData do
  use BorshEx.Schema

  defstruct a: nil, b: nil, c: nil

  schema do
    field :a, "u8"
    field :b, "u64"
    field :c, "string"
  end
end
