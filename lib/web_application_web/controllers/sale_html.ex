defmodule WebApplicationWeb.SaleHTML do
  use WebApplicationWeb, :html

  embed_templates "sale_html/*"

  @doc """
  Renders a sale form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :books, :list, required: true

  def sale_form(assigns)

  @doc """
  Formats sales numbers with commas for better readability.
  """
  def format_sales(sales) when is_integer(sales) do
    sales
    |> Integer.to_string()
    |> String.replace(~r/(\d)(?=(\d{3})+$)/, "\\1,")
  end

  def format_sales(_), do: "0"

  @doc """
  Generates the sort path for the book column, toggling between asc and desc.
  """
  def book_sort_path(params) do
    current_sort = params["sort_by"]
    current_order = params["sort_order"] || "asc"

    new_order =
      case {current_sort, current_order} do
        {"book_name", "asc"} -> "desc"
        {"book_name", "desc"} -> "asc"
        _ -> "asc"
      end

    ~p"/sales?sort_by=book_name&sort_order=#{new_order}"
  end
end
