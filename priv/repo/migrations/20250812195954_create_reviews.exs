defmodule WebApplication.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :book_id, references(:books, on_delete: :delete_all), null: false
      add :review, :text, null: false
      add :score, :integer, null: false
      add :number_of_upvotes, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:book_id])
    create index(:reviews, [:score])
    create constraint(:reviews, :score_range, check: "score >= 1 AND score <= 5")
    create constraint(:reviews, :upvotes_positive, check: "number_of_upvotes >= 0")
  end
end
