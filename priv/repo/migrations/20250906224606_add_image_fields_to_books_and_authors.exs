defmodule WebApplication.Repo.Migrations.AddImageFieldsToBooksAndAuthors do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :cover_image_url, :string
    end

    alter table(:authors) do
      add :profile_image_url, :string
    end
  end
end
