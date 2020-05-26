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

  Now, wherever you can use an `Ecto.Type` you cn use your module, so if you used the first approach
  then you can just define a field with your newly generated type:

  ```
  defmodule MyOtherSchema do
    use Ecto.Schema

    schema "table" do
      field(:name, MySchema)
    end
  end
  ```

  And make sure your migration has type `:map`.

  And you can even use it as primary key if you want, just use

  ```
  @primary_key {:id, MySchema, autogenerate: false}
  ```
  """

  defmacro __using__(schema: schema) do
    quote do
      @behaviour Ecto.Type

      def type, do: :map

      def cast(value) do
        with {:error, _} <- EctoMorph.cast_to_struct(value, unquote(schema)), do: :error
      end

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
