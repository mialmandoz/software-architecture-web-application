defmodule WebApplication.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string, null: false
      add :summary, :text
      add :date_of_publication, :date
      add :number_of_sales, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:books, [:name])
    create index(:books, [:date_of_publication])
  end
end
