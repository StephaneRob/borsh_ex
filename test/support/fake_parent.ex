defmodule BorshEx.FakeParent do
  use BorshEx.Schema

  defstruct l: nil, b: nil

  borsh_schema do
    field :l, "string"
    field :b, BorshEx.FakeData
  end
end
