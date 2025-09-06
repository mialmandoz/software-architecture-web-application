defmodule WebApplicationWeb.BookController do
  use WebApplicationWeb, :controller

  alias WebApplication.Books
  alias WebApplication.Books.Book
  alias WebApplication.Authors
  alias WebApplication.Search
  alias WebApplication.FileUpload

  def index(conn, params) do
    page = Books.list_books(params)
    filter_name = Map.get(params, "filter_name", "")
    filter_author = Map.get(params, "filter_author", "")
    filter_summary = Map.get(params, "filter_summary", "")

    render(conn, :index,
      page: page,
      books: page.entries,
      filter_name: filter_name,
      filter_author: filter_author,
      filter_summary: filter_summary,
      search_available: Search.available?()
    )
  end

  def search(conn, %{"search" => %{"q" => query}, "page" => page})
      when is_binary(query) and query != "" do
    page = String.to_integer(page)
    {books, pagination} = Books.search_books(query, page: page, per_page: 10)
    render(conn, :search, books: books, query: query, pagination: pagination)
  end

  def search(conn, %{"search" => %{"q" => query}}) when is_binary(query) and query != "" do
    page = String.to_integer(conn.params["page"] || "1")
    {books, pagination} = Books.search_books(query, page: page, per_page: 10)
    render(conn, :search, books: books, query: query, pagination: pagination)
  end

  def search(conn, %{"q" => query, "page" => page}) when is_binary(query) and query != "" do
    page = String.to_integer(page)
    {books, pagination} = Books.search_books(query, page: page, per_page: 10)
    render(conn, :search, books: books, query: query, pagination: pagination)
  end

  def search(conn, %{"q" => query}) when is_binary(query) and query != "" do
    page = String.to_integer(conn.params["page"] || "1")
    {books, pagination} = Books.search_books(query, page: page, per_page: 10)
    render(conn, :search, books: books, query: query, pagination: pagination)
  end

  def search(conn, _params) do
    render(conn, :search,
      books: [],
      query: "",
      pagination: %{page_number: 1, page_size: 10, total_entries: 0, total_pages: 0}
    )
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
    authors = Authors.list_all_authors()
    render(conn, :new, changeset: changeset, authors: authors)
  end

  def create(conn, %{"book" => book_params}) do
    book_params_with_image = handle_cover_image_upload(book_params)

    case Books.create_book(book_params_with_image) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: ~p"/books/#{book}")

      {:error, %Ecto.Changeset{} = changeset} ->
        authors = Authors.list_all_authors()
        render(conn, :new, changeset: changeset, authors: authors)
    end
  end

  def edit(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    changeset = Books.change_book(book)
    authors = Authors.list_all_authors()
    render(conn, :edit, book: book, changeset: changeset, authors: authors)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Books.get_book!(id)
    book_params_with_image = handle_cover_image_upload(book_params, book.cover_image_url)

    case Books.update_book(book, book_params_with_image) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: ~p"/books/#{book}")

      {:error, %Ecto.Changeset{} = changeset} ->
        authors = Authors.list_all_authors()
        render(conn, :edit, book: book, changeset: changeset, authors: authors)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Books.get_book!(id)

    # Delete the cover image file if it exists
    if book.cover_image_url do
      FileUpload.delete_image(book.cover_image_url)
    end

    {:ok, _book} = Books.delete_book(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: ~p"/books")
  end

  defp handle_cover_image_upload(book_params, existing_image_url \\ nil) do
    case Map.get(book_params, "cover_image") do
      %Plug.Upload{} = upload ->
        case FileUpload.upload_image(upload, :book_cover) do
          {:ok, image_url} ->
            # Delete old image if updating
            if existing_image_url, do: FileUpload.delete_image(existing_image_url)
            Map.put(book_params, "cover_image_url", image_url)

          {:error, _reason} ->
            book_params
        end

      _ ->
        book_params
    end
    |> Map.delete("cover_image")
  end
end
