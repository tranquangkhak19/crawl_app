defmodule Crawlapp.Repo.Migrations.AddCategoryToFilm do
  use Ecto.Migration

  def change do
    alter table(:films) do
      add :category, :string
    end
  end
end
