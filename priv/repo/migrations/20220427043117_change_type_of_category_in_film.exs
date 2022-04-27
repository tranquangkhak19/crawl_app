defmodule Crawlapp.Repo.Migrations.ChangeTypeOfCategoryInFilm do
  use Ecto.Migration

  def change do
    alter table(:films) do
      remove :category
      add :category, :integer
    end
  end
end
