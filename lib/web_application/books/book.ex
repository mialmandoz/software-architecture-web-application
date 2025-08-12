defmodule WebApplication.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :name, :string
    field :summary, :string
    field :date_of_publication, :date
    field :number_of_sales, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :summary, :date_of_publication, :number_of_sales])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_number(:number_of_sales, greater_than_or_equal_to: 0)
  end
end
