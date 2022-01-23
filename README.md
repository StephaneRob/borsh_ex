# BorshEx

:warning: Work in progress

Elixir implementation of Binary Object Representation Serializer for Hashing ([borsh](https://borsh.io))

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `borsh_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:borsh_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/borsh_ex](https://hexdocs.pm/borsh_ex).

## Usage

```elixir
defmodule BorshEx.FakeData do
  use BorshEx.Schema

  defstruct a: nil, b: nil, c: nil

  borsh_schema do
    field :a, "u8"
    field :b, "u64"
    field :c, "string"
  end
end
```

## Copyright and License

Copyright (c) 2022, Stéphane Robino
This library is licensed under the BSD-2-Clause.
