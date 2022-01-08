defmodule BorshEx.FakeParent do
  use BorshEx.Schema

  defstruct l: nil, b: nil

  schema do
    field :l, "string"
    field :b, BorshEx.FakeData
  end
end
