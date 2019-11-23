defmodule EctoEmbeddedTypeTest do
  use ExUnit.Case

  defmodule Schema do
    use Ecto.Schema
    use EctoEmbeddedType

    @primary_key false
    embedded_schema do
      field(:x, :string)
    end
  end

  defmodule OtherSchema do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field(:x, :string)
    end
  end

  describe "using with no arguments" do
    test "type/0 returns :map" do
      assert Schema.type() == :map
    end

    test "dump/1 saves the value as the encoded value" do
      assert EctoEmbeddedType.Codec.encode(%Schema{x: "x"}) ==
               Schema.dump(%Schema{x: "x"})
    end

    test "dump/1 returns an error for other values" do
      assert :error = Schema.dump(%OtherSchema{x: "x"})
    end

    test "we can dump and load correctly" do
      {:ok, dumped} = Schema.dump(%Schema{x: "x"})
      assert {:ok, %Schema{x: "x"}} == Schema.load(dumped)
    end
  end

  describe "using with a schema argument" do
    defmodule MyType do
      use EctoEmbeddedType, schema: Schema
    end

    test "type/0 returns :map" do
      assert MyType.type() == :map
    end

    test "dump/1 saves the value as the encoded value" do
      assert EctoEmbeddedType.Codec.encode(%Schema{x: "x"}) ==
               MyType.dump(%Schema{x: "x"})
    end

    test "dump/1 returns an error for other values" do
      assert :error = MyType.dump(%OtherSchema{x: "x"})
    end

    test "we can dump and load correctly" do
      {:ok, dumped} = MyType.dump(%Schema{x: "x"})
      assert {:ok, %Schema{x: "x"}} == MyType.load(dumped)
    end
  end
end
