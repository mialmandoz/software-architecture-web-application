defmodule WebApplicationWeb.ReviewController do
  use WebApplicationWeb, :controller

  alias WebApplication.Reviews
  alias WebApplication.Reviews.Review
  alias WebApplication.Books

  def index(conn, _params) do
    reviews = Reviews.list_reviews()
    render(conn, :index, reviews: reviews)
  end

  def show(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    render(conn, :show, review: review)
  end

  def new(conn, _params) do
    changeset = Reviews.change_review(%Review{})
    books = Books.list_books()
    render(conn, :new, changeset: changeset, books: books)
  end

  def create(conn, %{"review" => review_params}) do
    case Reviews.create_review(review_params) do
      {:ok, review} ->
        conn
        |> put_flash(:info, "Review created successfully.")
        |> redirect(to: ~p"/reviews/#{review}")

      {:error, %Ecto.Changeset{} = changeset} ->
        books = Books.list_books()
        render(conn, :new, changeset: changeset, books: books)
    end
  end

  def edit(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    changeset = Reviews.change_review(review)
    books = Books.list_books()
    render(conn, :edit, review: review, changeset: changeset, books: books)
  end

  def update(conn, %{"id" => id, "review" => review_params}) do
    review = Reviews.get_review!(id)

    case Reviews.update_review(review, review_params) do
      {:ok, review} ->
        conn
        |> put_flash(:info, "Review updated successfully.")
        |> redirect(to: ~p"/reviews/#{review}")

      {:error, %Ecto.Changeset{} = changeset} ->
        books = Books.list_books()
        render(conn, :edit, review: review, changeset: changeset, books: books)
    end
  end

  def delete(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    {:ok, _review} = Reviews.delete_review(review)

    conn
    |> put_flash(:info, "Review deleted successfully.")
    |> redirect(to: ~p"/reviews")
  end
end
