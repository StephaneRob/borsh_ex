# BorshEx

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

## Validation

Schemas support `u8`, `u16`, `u32`, `u64`, `i8`, `i16`, `i32`, `i64`,
`boolean`, UTF-8 `string`, nested schema modules, and enums. Arrays and options
can contain any supported type, including other arrays and options:

```elixir
field :flags, {"array", "boolean"}
field :matrix, {"array", {"array", "u16"}}
field :optional_flags, {"array", {"option", "boolean"}}
field :coordinates, {"array", {"i32", 3}}
```

Only `nil` represents an absent option; `false` is encoded as a present value.
Fixed arrays must have exactly the declared number of elements. Integers must
fit their declared range, booleans must be `true` or `false`, strings must be
valid UTF-8, and enums must have between 1 and 256 variants.

Invalid values, invalid tags, and truncated input raise `ArgumentError`.
Successful deserialization returns `{:ok, struct}`. Extra bytes return
`{:error, struct, remaining_bytes}` as before. Applications handling untrusted
input should enforce appropriate payload and collection size limits.

## Copyright and License

Copyright (c) 2022-2026, Stéphane Robino
This library is licensed under the BSD-2-Clause.
