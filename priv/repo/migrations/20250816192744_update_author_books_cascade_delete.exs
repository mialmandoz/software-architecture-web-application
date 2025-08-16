defmodule WebApplication.Repo.Migrations.UpdateAuthorBooksCascadeDelete do
  use Ecto.Migration

  def up do
    # Drop the existing foreign key constraint
    drop constraint(:books, "books_author_id_fkey")

    # Add the new foreign key constraint with cascade delete
    alter table(:books) do
      modify :author_id, references(:authors, on_delete: :delete_all)
    end
  end

  def down do
    # Drop the cascade delete constraint
    drop constraint(:books, "books_author_id_fkey")

    # Restore the original nilify_all constraint
    alter table(:books) do
      modify :author_id, references(:authors, on_delete: :nilify_all)
    end
  end
end
