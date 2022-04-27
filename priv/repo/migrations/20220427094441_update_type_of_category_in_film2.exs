defmodule Crawlapp.Repo.Migrations.UpdateTypeOfCategoryInFilm2 do
  use Ecto.Migration

  def change do
    alter table(:films) do
      remove :category
      add :category, references("category")
    end
  end
end
