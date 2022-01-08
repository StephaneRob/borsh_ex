defmodule BorshEx.FakeSubData do
  use BorshEx.Schema

  defstruct a: nil, b: nil, c: nil, d: nil, e: nil, f: nil, g: nil, h: nil, i: nil, j: nil, k: nil

  schema do
    field :a, "string"
    field :b, "u64"
    field :c, "u8"
    field :d, {"array", "u8"}
    field :e, {"array", {"u16", 10}}
    field :f, "boolean"
    field :g, "boolean"
    field :h, {"option", "u8"}
    field :i, {"option", "string"}
    field :j, {"array", {"string", 3}}
    field :k, "i8"
  end
end
