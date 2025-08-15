defmodule WebApplicationWeb.BookController do
  use WebApplicationWeb, :controller

  alias WebApplication.Books
  alias WebApplication.Books.Book
  alias WebApplication.Authors

  def index(conn, params) do
    books = Books.list_books(params)
    filter_name = Map.get(params, "filter_name", "")
    filter_author = Map.get(params, "filter_author", "")
    render(conn, :index, books: books, filter_name: filter_name, filter_author: filter_author)
  end

  def top_rated(conn, _params) do
    top_books = Books.get_top_rated_books()
    render(conn, :top_rated, top_books: top_books)
  end

  def top_selling(conn, _params) do
    top_selling_books = Books.get_top_selling_books()
    render(conn, :top_selling, top_selling_books: top_selling_books)
  end

  def show(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    render(conn, :show, book: book)
  end

  def new(conn, _params) do
    changeset = Books.change_book(%Book{})
    authors = Authors.list_authors()
    render(conn, :new, changeset: changeset, authors: authors)
  end

  def create(conn, %{"book" => book_params}) do
    case Books.create_book(book_params) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: ~p"/books/#{book}")

      {:error, %Ecto.Changeset{} = changeset} ->
        authors = Authors.list_authors()
        render(conn, :new, changeset: changeset, authors: authors)
    end
  end

  def edit(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    changeset = Books.change_book(book)
    authors = Authors.list_authors()
    render(conn, :edit, book: book, changeset: changeset, authors: authors)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Books.get_book!(id)

    case Books.update_book(book, book_params) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: ~p"/books/#{book}")

      {:error, %Ecto.Changeset{} = changeset} ->
        authors = Authors.list_authors()
        render(conn, :edit, book: book, changeset: changeset, authors: authors)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    {:ok, _book} = Books.delete_book(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: ~p"/books")
  end
end
