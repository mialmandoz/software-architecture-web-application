defmodule WebApplicationWeb.AuthorHTML do
  use WebApplicationWeb, :html

  embed_templates "author_html/*"

  @doc """
  Renders an author form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def author_form(assigns)
end
