defmodule WebApplication.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :book_id, references(:books, on_delete: :delete_all), null: false
      add :year, :integer, null: false
      add :sales, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sales, [:book_id])
    create index(:sales, [:year])
    create unique_index(:sales, [:book_id, :year])
    create constraint(:sales, :year_range, check: "year >= 1000 AND year <= 2100")
    create constraint(:sales, :sales_positive, check: "sales >= 0")
  end
end
