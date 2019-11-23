defmodule EctoEmbeddedType.CodecTest do
  use ExUnit.Case

  alias EctoEmbeddedType.Codec

  defmodule NestedSchema do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field(:foo, :string)
    end
  end

  defmodule EmbeddedSchema do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field(:integer, :integer)
      field(:float, :float)
      field(:boolean, :boolean)
      field(:string, :string)
      field(:binary, :binary)
      # field(:decimal, :decimal)

      field(:id, :id)
      field(:binary_id, :binary_id)

      field(:utc_datetime, :utc_datetime)
      field(:naive_datetime, :naive_datetime)
      field(:time, :time)

      field(:utc_datetime_usec, :utc_datetime_usec)
      field(:naive_datetime_usec, :naive_datetime_usec)
      field(:time_usec, :time_usec)

      field(:date, :date)

      field(:int_array, {:array, :integer})
      field(:map, :map)
      embeds_one(:ns, NestedSchema)
      embeds_many(:nss, NestedSchema)
    end
  end

  setup do
    {:ok, date} = Date.new(2000, 1, 1)
    uuid = Ecto.UUID.generate()
    dt = DateTime.utc_now()
    ndt = NaiveDateTime.utc_now()
    t = Time.utc_now()

    tdt = dt |> DateTime.truncate(:second)
    tndt = ndt |> NaiveDateTime.truncate(:second)
    tt = t |> Time.truncate(:second)

    %{
      schema: %EmbeddedSchema{
        integer: 1,
        float: 1.1,
        boolean: true,
        string: "string",
        binary: <<1::8>>,
        id: 1,
        binary_id: uuid,
        utc_datetime: tdt,
        naive_datetime: tndt,
        time: tt,
        utc_datetime_usec: dt,
        naive_datetime_usec: ndt,
        time_usec: t,
        date: date,
        int_array: [1, 2, 3, 4],
        map: %{"foo" => "bar"},
        ns: %NestedSchema{foo: "ns_foo_val"},
        nss: [
          %NestedSchema{foo: "nss_1_foo_val"},
          %NestedSchema{foo: "nss_2_foo_val"}
        ]
      },
      encoded: %{
        "integer" => 1,
        "float" => 1.1,
        "boolean" => true,
        "string" => "string",
        "binary" => Base.encode64(<<1::8>>),
        "id" => 1,
        "binary_id" => uuid,
        "utc_datetime" => tdt |> DateTime.to_iso8601(),
        "naive_datetime" => tndt |> NaiveDateTime.to_iso8601(),
        "time" => tt |> Time.to_iso8601(),
        "utc_datetime_usec" => dt |> DateTime.to_iso8601(),
        "naive_datetime_usec" => ndt |> NaiveDateTime.to_iso8601(),
        "time_usec" => t |> Time.to_iso8601(),
        "int_array" => [1, 2, 3, 4],
        "date" => "2000-01-01",
        "map" => %{"foo" => "bar"},
        "ns" => %{"foo" => "ns_foo_val"},
        "nss" => [
          %{"foo" => "nss_1_foo_val"},
          %{"foo" => "nss_2_foo_val"}
        ]
      }
    }
  end

  describe "encode/1" do
    test "encodes into a JSON-like map", ctx do
      assert {:ok, ctx.encoded} == Codec.encode(ctx.schema)
    end

    test "it encodes maps with non-json types", ctx do
      strange_map = %{
        :foo => {1, 2},
        "bar" => :baz,
        %{} => "test"
      }

      schema = %EmbeddedSchema{ctx.schema | map: strange_map}
      encoded_map_key = %{} |> :erlang.term_to_binary() |> Base.encode64()
      {:ok, encoded} = Codec.encode(schema)

      assert encoded["map"] == %{
               "foo" => [1, 2],
               "bar" => "baz",
               encoded_map_key => "test"
             }
    end
  end

  describe "decode/2" do
    test "decodes back to the schema struct", ctx do
      assert {:ok, ctx.schema} == Codec.decode(EmbeddedSchema, ctx.encoded)
    end
  end
end
