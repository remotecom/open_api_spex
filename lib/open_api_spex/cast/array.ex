defmodule OpenApiSpex.Cast.Array do
  @moduledoc false
  alias OpenApiSpex.Cast
  alias OpenApiSpex.Schema

  def cast(%{value: [], schema: %{itemsMeta: nil}}) do
    {:ok, []}
  end

  def cast(%{value: [], schema: %{itemsMeta: %Schema.ItemsMeta{min: nil}}}) do
    {:ok, []}
  end

  def cast(%{value: items} = ctx) when is_list(items) do
    case cast_array(ctx) do
      {:cast, ctx} -> cast(ctx)
      {items, []} -> Cast.ok(%{ctx | value: items})
      {_, errors} -> {:error, errors}
    end
  end

  def cast(ctx),
    do: Cast.error(ctx, {:invalid_type, :array})

  ## Private functions
  defp cast_array(%{value: value, schema: %{itemsMeta: %Schema.ItemsMeta{min: min, max: max, unique: unique}}} = ctx) do
    item_count = Enum.count(value)

    if is_integer(min) and item_count < min do
      Cast.error(ctx, {:min_items, min, item_count})
    else
      if is_integer(max) and item_count > max do
        Cast.error(ctx, {:max_items, max, item_count})
      else
        if unique do
          unique_size =
            value
            |> MapSet.new()
            |> MapSet.size()

          if unique_size != Enum.count(value) do
            Cast.error(ctx, {:unique_items})
          else
            Cast.success(ctx, :itemsMeta)
          end
        else
          Cast.success(ctx, :itemsMeta)
        end
      end
    end
  end

  defp cast_array(%{value: items} = ctx) do
    cast_results =
      items
      |> Enum.with_index()
      |> Enum.map(fn {item, index} ->
        path = [index | ctx.path]
        Cast.cast(%{ctx | value: item, schema: ctx.schema.items, path: path})
      end)

    errors =
      for({:error, errors} <- cast_results, do: errors)
      |> Enum.concat()

    items = for {:ok, item} <- cast_results, do: item

    {items, errors}
  end
end
