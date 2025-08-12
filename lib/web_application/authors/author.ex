defmodule WebApplication.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :name, :string
    field :date_of_birth, :date
    field :country_of_origin, :string
    field :short_description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :date_of_birth, :country_of_origin, :short_description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:country_of_origin, max: 100)
    |> validate_length(:short_description, max: 1000)
  end
end
