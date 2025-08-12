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
end
