defmodule WebApplication.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  alias WebApplication.Authors.Author

  schema "books" do
    field :name, :string
    field :summary, :string
    field :date_of_publication, :date
    field :number_of_sales, :integer, default: 0
    belongs_to :author, Author

    has_many :reviews, WebApplication.Reviews.Review
    has_many :sales, WebApplication.Sales.Sale

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :summary, :date_of_publication, :number_of_sales, :author_id])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_number(:number_of_sales, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:author_id)
  end
end
