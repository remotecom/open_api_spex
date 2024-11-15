defmodule OpenApiSpex.Cast.Array do
  @moduledoc false
  alias OpenApiSpex.Cast
  alias OpenApiSpex.Schema.Items

  def cast(%{value: [], schema: %{items: nil}}) do
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

  defp cast_array(%{value: value, schema: %{items: %Items{min: minimum}}} = ctx)
       when is_integer(minimum) do
    item_count = Enum.count(value)

    if item_count < minimum do
      Cast.error(ctx, {:min_items, minimum, item_count})
    else
      Cast.success(ctx, :items)
    end
  end

  defp cast_array(%{value: value, schema: %{items: %Items{max: maximum}}} = ctx)
       when is_integer(maximum) do
    item_count = Enum.count(value)

    if item_count > maximum do
      Cast.error(ctx, {:max_items, maximum, item_count})
    else
      Cast.success(ctx, :items)
    end
  end

  defp cast_array(%{value: value, schema: %{items: %Items{unique: true}}} = ctx) do
    unique_size =
      value
      |> MapSet.new()
      |> MapSet.size()

    if unique_size != Enum.count(value) do
      Cast.error(ctx, {:unique_items})
    else
      Cast.success(ctx, :items)
    end
  end

  defp cast_array(%{value: items, schema: %{items: %Items{value: items_config}}} = ctx) do
    cast_results =
      items
      |> Enum.with_index()
      |> Enum.map(fn {item, index} ->
        path = [index | ctx.path]
        Cast.cast(%{ctx | value: item, schema: items_config, path: path})
      end)

    errors =
      for({:error, errors} <- cast_results, do: errors)
      |> Enum.concat()

    items = for {:ok, item} <- cast_results, do: item

    {items, errors}
  end

  defp cast_array(%{value: items, schema: %{items: items_config}} = ctx) do
    cast_results =
      items
      |> Enum.with_index()
      |> Enum.map(fn {item, index} ->
        path = [index | ctx.path]
        Cast.cast(%{ctx | value: item, schema: items_config, path: path})
      end)

    errors =
      for({:error, errors} <- cast_results, do: errors)
      |> Enum.concat()

    items = for {:ok, item} <- cast_results, do: item

    {items, errors}
  end
end
