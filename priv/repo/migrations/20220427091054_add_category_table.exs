defmodule Crawlapp.Repo.Migrations.AddCategoryTable do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :category, :string
    end
  end
end
