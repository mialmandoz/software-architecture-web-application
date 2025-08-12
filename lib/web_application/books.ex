defmodule WebApplication.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias WebApplication.Repo

  alias WebApplication.Books.Book

  @doc """
  Returns the list of books with optional filtering.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

      iex> list_books(%{"filter_name" => "gatsby"})
      [%Book{}, ...]

  """
  def list_books(params \\ %{}) do
    filter_name = Map.get(params, "filter_name", "")
    filter_author = Map.get(params, "filter_author", "")

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

    # Order by book name for consistent display
    query = from [b, a] in query, order_by: [asc: b.name]

    Repo.all(query)
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
end
