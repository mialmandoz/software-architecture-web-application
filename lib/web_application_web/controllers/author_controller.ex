defmodule WebApplicationWeb.AuthorController do
  use WebApplicationWeb, :controller

  alias WebApplication.Authors
  alias WebApplication.Authors.Author
  alias WebApplication.FileUpload

  def index(conn, params) do
    page = Authors.list_authors(params)
    filter_name = Map.get(params, "filter_name", "")
    filter_country = Map.get(params, "filter_country", "")

    render(conn, :index,
      page: page,
      authors: page.entries,
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
    author_params_with_image = handle_profile_image_upload(author_params)

    case Authors.create_author(author_params_with_image) do
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

    author_params_with_image =
      handle_profile_image_upload(author_params, author.profile_image_url)

    case Authors.update_author(author, author_params_with_image) do
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

    # Delete the profile image file if it exists
    if author.profile_image_url do
      FileUpload.delete_image(author.profile_image_url)
    end

    {:ok, _author} = Authors.delete_author(author)

    conn
    |> put_flash(:info, "Author deleted successfully.")
    |> redirect(to: ~p"/authors")
  end

  defp handle_profile_image_upload(author_params, existing_image_url \\ nil) do
    case Map.get(author_params, "profile_image") do
      %Plug.Upload{} = upload ->
        case FileUpload.upload_image(upload, :author_profile) do
          {:ok, image_url} ->
            # Delete old image if updating
            if existing_image_url, do: FileUpload.delete_image(existing_image_url)
            Map.put(author_params, "profile_image_url", image_url)

          {:error, _reason} ->
            author_params
        end

      _ ->
        author_params
    end
    |> Map.delete("profile_image")
  end
end
