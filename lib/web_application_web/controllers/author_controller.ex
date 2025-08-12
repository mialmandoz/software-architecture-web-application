defmodule WebApplicationWeb.AuthorController do
  use WebApplicationWeb, :controller

  alias WebApplication.Authors
  alias WebApplication.Authors.Author

  def index(conn, params) do
    authors = Authors.list_authors(params)
    filter_name = Map.get(params, "filter_name", "")
    filter_country = Map.get(params, "filter_country", "")

    render(conn, :index,
      authors: authors,
      filter_name: filter_name,
      filter_country: filter_country
    )
  end

  def statistics(conn, params) do
    sort_by = Map.get(params, "sort_by", "name")
    sort_order = Map.get(params, "sort_order", "asc")
    filter_name = Map.get(params, "filter_name", "")

    author_stats = Authors.get_author_statistics(sort_by, sort_order, filter_name)

    render(conn, :statistics,
      author_stats: author_stats,
      sort_by: sort_by,
      sort_order: sort_order,
      filter_name: filter_name
    )
  end

  def show(conn, %{"id" => id}) do
    author = Authors.get_author!(id)
    render(conn, :show, author: author)
  end

  def new(conn, _params) do
    changeset = Authors.change_author(%Author{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"author" => author_params}) do
    case Authors.create_author(author_params) do
      {:ok, author} ->
        conn
        |> put_flash(:info, "Author created successfully.")
        |> redirect(to: ~p"/authors/#{author}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    author = Authors.get_author!(id)
    changeset = Authors.change_author(author)
    render(conn, :edit, author: author, changeset: changeset)
  end

  def update(conn, %{"id" => id, "author" => author_params}) do
    author = Authors.get_author!(id)

    case Authors.update_author(author, author_params) do
      {:ok, author} ->
        conn
        |> put_flash(:info, "Author updated successfully.")
        |> redirect(to: ~p"/authors/#{author}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, author: author, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    author = Authors.get_author!(id)
    {:ok, _author} = Authors.delete_author(author)

    conn
    |> put_flash(:info, "Author deleted successfully.")
    |> redirect(to: ~p"/authors")
  end
end
