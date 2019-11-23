defmodule EctoEmbeddedType do
  @moduledoc """
  Transforms an Ecto embedded schema into an Ecto.Type that maps to `:map` type.

  You can just use it on the same module as your schema

  ```
  defmodule MySchema do
    use Ecto.Schema
    use EctoEmbeddedType

    #... define your embedded schema
  end
  ```

  Or, if you want, you may define the Ecto Type in another module.

  ```
  defmodule MyType do
    use EctoEmbeddedType, schema: MySchema
  end
  ```
  """

  defmacro __using__(schema: schema) do
    quote do
      @behaviour Ecto.Type

      def type, do: :map

      def cast(%{__struct__: unquote(schema)} = value), do: {:ok, value}
      def cast(_), do: :error

      def load(data) do
        EctoEmbeddedType.Codec.decode(unquote(schema), data)
      end

      def dump(%{__struct__: unquote(schema)} = value) do
        EctoEmbeddedType.Codec.encode(value)
      end

      def dump(_), do: :error

      def embed_as(_), do: :dump

      # Use structural equality by default.
      def equal?(a, b), do: a == b
      defoverridable equal?: 2
    end
  end

  defmacro __using__([]) do
    quote do
      use EctoEmbeddedType, schema: __MODULE__
    end
  end
end
