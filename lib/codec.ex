defmodule EctoEmbeddedType.Codec do
  @moduledoc false

  @type encoded_map :: %{required(String.t()) => encoded()}
  @type encoded_list :: [encoded()]

  @iso8601_types [
    :utc_datetime,
    :naive_datetime,
    :time,
    :utc_datetime_usec,
    :naive_datetime_usec,
    :time_usec,
    :date
  ]

  @type encoded ::
          encoded_map()
          | encoded_list()
          | String.t()
          | number()
          | boolean()
          | nil

  @spec encode(value :: any()) :: {:ok, encoded_map()} | :error
  def encode(%{__struct__: schema} = value) do
    type = {:embed, Ecto.Embedded.struct(__MODULE__, :field, cardinality: :one, related: schema)}

    with {:ok, data} <- dump_embed(type, value) do
      {:ok, ensure_encoded(data)}
    end
  end

  @spec decode(schema :: atom(), encoded_map()) :: {:ok, any()} | :error
  def decode(schema, value) do
    type = {:embed, Ecto.Embedded.struct(__MODULE__, :field, cardinality: :one, related: schema)}
    load_embed(type, value)
  end

  defp dump_embed(type, value) do
    Ecto.Type.dump(type, value, fn
      {:embed, _} = type, value -> dump_embed(type, value)
      type, value when type in @iso8601_types -> {:ok, to_iso8601(type, value)}
      :binary, value -> {:ok, Base.encode64(value)}
      _type, value -> {:ok, value}
    end)
  end

  defp load_embed(type, value) do
    Ecto.Type.load(type, value, fn
      {:embed, _} = type, value ->
        load_embed(type, value)

      :binary, encoded ->
        case Base.decode64(encoded) do
          {:ok, decoded} -> {:ok, decoded}
          _ -> :error
        end

      type, value ->
        case Ecto.Type.cast(type, value) do
          {:ok, _} = ok -> ok
          _ -> :error
        end
    end)
  end

  defguard is_scalar(val)
           when is_binary(val) or is_nil(val) or is_number(val) or is_boolean(val)

  defp ensure_encoded(data) when is_scalar(data), do: data

  defp ensure_encoded(data) when is_list(data) do
    Enum.map(data, &ensure_encoded/1)
  end

  defp ensure_encoded(data) when is_map(data) do
    data
    |> Enum.map(fn {k, v} -> {stringify(k), ensure_encoded(v)} end)
    |> Map.new()
  end

  defp ensure_encoded(data) when is_atom(data), do: to_string(data)

  defp ensure_encoded(data) when is_tuple(data) do
    data
    |> Tuple.to_list()
    |> ensure_encoded()
  end

  defp stringify(val) when is_binary(val), do: val
  defp stringify(val) when is_atom(val), do: to_string(val)
  defp stringify(val), do: val |> :erlang.term_to_binary() |> Base.encode64()

  defp to_iso8601(:naive_datetime, value), do: NaiveDateTime.to_iso8601(value)
  defp to_iso8601(:naive_datetime_usec, value), do: NaiveDateTime.to_iso8601(value)
  defp to_iso8601(:utc_datetime, value), do: DateTime.to_iso8601(value)
  defp to_iso8601(:utc_datetime_usec, value), do: DateTime.to_iso8601(value)
  defp to_iso8601(:time, value), do: Time.to_iso8601(value)
  defp to_iso8601(:time_usec, value), do: Time.to_iso8601(value)
  defp to_iso8601(:date, value), do: Date.to_iso8601(value)
end
