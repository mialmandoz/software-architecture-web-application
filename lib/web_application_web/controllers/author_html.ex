defmodule WebApplicationWeb.AuthorHTML do
  use WebApplicationWeb, :html

  embed_templates "author_html/*"

  @doc """
  Renders an author form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def author_form(assigns)

  @doc """
  Formats numbers with commas for better readability.
  """
  def format_number(number) when is_integer(number) do
    number
    |> Integer.to_string()
    |> String.replace(~r/(\d)(?=(\d{3})+$)/, "\\1,")
  end

  def format_number(number) when is_float(number) do
    :erlang.float_to_binary(number, decimals: 1)
  end

  def format_number(_), do: "0"

  @doc """
  Creates a sort link with proper parameters.
  """
  def sort_link(sort_by, current_sort_by, current_sort_order, filter_name) do
    new_sort_order =
      if sort_by == current_sort_by and current_sort_order == "asc", do: "desc", else: "asc"

    params = %{
      "sort_by" => sort_by,
      "sort_order" => new_sort_order,
      "filter_name" => filter_name
    }

    {params, new_sort_order}
  end

  @doc """
  Gets the sort arrow for display.
  """
  def sort_arrow(column, current_sort_by, current_sort_order) do
    if column == current_sort_by do
      if current_sort_order == "asc", do: "↑", else: "↓"
    else
      ""
    end
  end
end
