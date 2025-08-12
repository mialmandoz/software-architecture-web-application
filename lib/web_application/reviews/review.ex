defmodule WebApplication.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  alias WebApplication.Books.Book

  schema "reviews" do
    field :review, :string
    field :score, :integer
    field :number_of_upvotes, :integer, default: 0
    belongs_to :book, Book

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:book_id, :review, :score, :number_of_upvotes])
    |> validate_required([:book_id, :review, :score])
    |> validate_length(:review, min: 10, max: 2000)
    |> validate_number(:score, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:number_of_upvotes, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:book_id)
  end
end
