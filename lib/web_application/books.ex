defmodule WebApplication.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias WebApplication.Repo

  alias WebApplication.Books.Book
  alias WebApplication.Reviews.Review

  @doc """
  Returns a paginated list of books with optional filtering.

  ## Examples

      iex> list_books()
      %Scrivener.Page{entries: [%Book{}, ...], ...}

      iex> list_books(%{"filter_name" => "gatsby", "page" => "2"})
      %Scrivener.Page{entries: [%Book{}, ...], ...}

  """
  def list_books(params \\ %{}) do
    filter_name = Map.get(params, "filter_name", "")
    filter_author = Map.get(params, "filter_author", "")
    filter_summary = Map.get(params, "filter_summary", "")
    page = Map.get(params, "page", "1") |> String.to_integer()

    query =
      from b in Book,
        join: a in assoc(b, :author),
        preload: [author: a]

    # Apply book name filter
    query =
      if filter_name != "" do
        from [b, a] in query,
          where: ilike(b.name, ^"%#{filter_name}%")
      else
        query
      end

    # Apply author name filter
    query =
      if filter_author != "" do
        from [b, a] in query,
          where: ilike(a.name, ^"%#{filter_author}%")
      else
        query
      end

    # Apply summary filter
    query =
      if filter_summary != "" do
        from [b, a] in query,
          where: ilike(b.summary, ^"%#{filter_summary}%")
      else
        query
      end

    # Order by book name for consistent display
    query = from [b, a] in query, order_by: [asc: b.name]

    Repo.paginate(query, page: page, page_size: 10)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id) do
    Repo.get!(Book, id)
    |> Repo.preload(:author)
  end

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  @doc """
  Gets the top 10 rated books with their best and worst reviews.
  Books are sorted by average review score (highest first).
  For each book, returns the highest-rated review and lowest-rated review
  (with most upvotes as tiebreaker).

  ## Examples

      iex> get_top_rated_books()
      [%{book: %Book{}, author: %Author{}, avg_score: 4.5, best_review: %Review{}, worst_review: %Review{}}, ...]

  """
  def get_top_rated_books() do
    # Get books with their average review scores
    books_with_avg_scores =
      from b in Book,
        join: r in assoc(b, :reviews),
        join: a in assoc(b, :author),
        group_by: [b.id, a.id],
        select: %{
          book_id: b.id,
          book: b,
          author: a,
          avg_score: avg(r.score)
        },
        order_by: [desc: avg(r.score)],
        limit: 10

    top_books = Repo.all(books_with_avg_scores)

    # For each top book, get the best and worst reviews
    Enum.map(top_books, fn book_data ->
      best_review = get_best_review_for_book(book_data.book_id)
      worst_review = get_worst_review_for_book(book_data.book_id)

      Map.merge(book_data, %{
        best_review: best_review,
        worst_review: worst_review
      })
    end)
  end

  defp get_best_review_for_book(book_id) do
    from(r in Review,
      where: r.book_id == ^book_id,
      order_by: [desc: r.score, desc: r.number_of_upvotes],
      limit: 1
    )
    |> Repo.one()
  end

  defp get_worst_review_for_book(book_id) do
    from(r in Review,
      where: r.book_id == ^book_id,
      order_by: [asc: r.score, desc: r.number_of_upvotes],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Gets the top 50 selling books of all time with their total sales,
  author's total sales, and whether they were in the top 5 for their publication year.

  ## Examples

      iex> get_top_selling_books()
      [%{book: %Book{}, author: %Author{}, book_sales: 1000000, author_total_sales: 5000000, top_5_in_year: true}, ...]

  """
  def get_top_selling_books() do
    # Get top 50 books by sales with author info
    top_books_query =
      from b in Book,
        join: a in assoc(b, :author),
        where: not is_nil(b.number_of_sales),
        order_by: [desc: b.number_of_sales],
        limit: 50,
        select: %{
          book: b,
          author: a,
          book_sales: b.number_of_sales
        }

    top_books = Repo.all(top_books_query)

    # For each book, calculate author's total sales and check if it was top 5 in publication year
    Enum.map(top_books, fn book_data ->
      author_total_sales = get_author_total_sales(book_data.author.id)
      top_5_in_year = is_book_top_5_in_publication_year?(book_data.book)

      Map.merge(book_data, %{
        author_total_sales: author_total_sales,
        top_5_in_year: top_5_in_year
      })
    end)
  end

  defp get_author_total_sales(author_id) do
    from(b in Book,
      where: b.author_id == ^author_id and not is_nil(b.number_of_sales),
      select: sum(b.number_of_sales)
    )
    |> Repo.one()
    |> case do
      nil -> 0
      total -> total
    end
  end

  defp is_book_top_5_in_publication_year?(%Book{date_of_publication: nil}), do: false

  defp is_book_top_5_in_publication_year?(%Book{date_of_publication: pub_date, id: book_id}) do
    pub_year = pub_date.year

    # Get top 5 books by sales for the publication year
    top_5_query =
      from b in Book,
        where:
          fragment("EXTRACT(year FROM ?)", b.date_of_publication) == ^pub_year and
            not is_nil(b.number_of_sales),
        order_by: [desc: b.number_of_sales],
        limit: 5,
        select: b.id

    top_5_ids = Repo.all(top_5_query)
    book_id in top_5_ids
  end
end
