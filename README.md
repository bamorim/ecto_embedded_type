# EctoEmbeddedType

Generates an `Ecto.Type` from an `Ecto.Schema.embedded_schema/1`.

That is useful if you want, for whatever reason, to:

- Integrate it with another library that requires an `Ecto.Type`
- You want to use a complex type as primary key (don't ask me why)
- Easily parse JSON input (using `dump/1` and `load/1`, because what they do is actually converting
  to a JSON-like value)

## Installation

The package can be installed by adding `ecto_embedded_type` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:ecto_embedded_type, "~> 0.1.0"}
  ]
end
```
