defmodule WebApplication.Repo.Migrations.AddAuthorToBooks do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :author_id, references(:authors, on_delete: :nilify_all)
    end

    create index(:books, [:author_id])
  end
end
