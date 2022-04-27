defmodule Crawlapp.Repo.Migrations.UniqueCategoryOnCategories do
  use Ecto.Migration

  def change do
    create unique_index(:categories, [:category])
  end
end
