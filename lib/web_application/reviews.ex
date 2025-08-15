defmodule WebApplication.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias WebApplication.Repo

  alias WebApplication.Reviews.Review

  @doc """
  Returns a paginated list of reviews, optionally filtered by book name.

  ## Examples

      iex> list_reviews()
      %Scrivener.Page{entries: [%Review{}, ...], ...}

      iex> list_reviews(%{"filter_book" => "Harry Potter", "page" => "2"})
      %Scrivener.Page{entries: [%Review{}, ...], ...}

  """
  def list_reviews(params \\ %{}) do
    page = Map.get(params, "page", "1") |> String.to_integer()

    query = from(r in Review, join: b in assoc(r, :book), preload: :book)

    query =
      case Map.get(params, "filter_book") do
        nil ->
          query

        "" ->
          query

        book_name ->
          from([r, b] in query, where: ilike(b.name, ^"%#{book_name}%"))
      end

    # Order by review ID for consistent pagination
    query = from [r, b] in query, order_by: [desc: r.id]

    Repo.paginate(query, page: page, page_size: 10)
  end

  @doc """
  Gets a single review.

  Raises `Ecto.NoResultsError` if the Review does not exist.

  ## Examples

      iex> get_review!(123)
      %Review{}

      iex> get_review!(456)
      ** (Ecto.NoResultsError)

  """
  def get_review!(id) do
    Repo.get!(Review, id)
    |> Repo.preload(:book)
  end

  @doc """
  Creates a review.

  ## Examples

      iex> create_review(%{field: value})
      {:ok, %Review{}}

      iex> create_review(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_review(attrs \\ %{}) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a review.

  ## Examples

      iex> update_review(review, %{field: new_value})
      {:ok, %Review{}}

      iex> update_review(review, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_review(%Review{} = review, attrs) do
    review
    |> Review.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a review.

  ## Examples

      iex> delete_review(review)
      {:ok, %Review{}}

      iex> delete_review(review)
      {:error, %Ecto.Changeset{}}

  """
  def delete_review(%Review{} = review) do
    Repo.delete(review)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking review changes.

  ## Examples

      iex> change_review(review)
      %Ecto.Changeset{data: %Review{}}

  """
  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end

  @doc """
  Returns the list of reviews for a specific book.

  ## Examples

      iex> list_reviews_for_book(book_id)
      [%Review{}, ...]

  """
  def list_reviews_for_book(book_id) do
    from(r in Review, where: r.book_id == ^book_id)
    |> Repo.all()
    |> Repo.preload(:book)
  end
end
