defmodule WebApplication.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :string, null: false
      add :date_of_birth, :date
      add :country_of_origin, :string
      add :short_description, :text

      timestamps(type: :utc_datetime)
    end

    create index(:authors, [:name])
    create index(:authors, [:country_of_origin])
  end
end
