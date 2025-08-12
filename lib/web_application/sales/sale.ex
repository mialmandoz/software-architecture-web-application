defmodule WebApplication.Sales.Sale do
  use Ecto.Schema
  import Ecto.Changeset

  alias WebApplication.Books.Book

  schema "sales" do
    field :year, :integer
    field :sales, :integer
    belongs_to :book, Book

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [:book_id, :year, :sales])
    |> validate_required([:book_id, :year, :sales])
    |> validate_number(:year, greater_than_or_equal_to: 1000, less_than_or_equal_to: 2100)
    |> validate_number(:sales, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:book_id)
    |> unique_constraint([:book_id, :year],
      message: "Sales record already exists for this book and year"
    )
  end
end
