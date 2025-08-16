defmodule WebApplicationWeb.ReviewHTML do
  use WebApplicationWeb, :html

  embed_templates "review_html/*"

  @doc """
  Renders a review form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :books, :list, required: true
  attr :review, :any, default: nil

  def review_form(assigns)

  @doc """
  Renders star rating display.
  """
  def star_rating(score) when is_integer(score) and score >= 1 and score <= 5 do
    filled_stars = String.duplicate("★", score)
    empty_stars = String.duplicate("☆", 5 - score)
    filled_stars <> empty_stars
  end

  def star_rating(_), do: "☆☆☆☆☆"
end
