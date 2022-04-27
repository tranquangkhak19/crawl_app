defmodule Crawlapp.Repo.Migrations.UniqueTitleOnFilms do
  use Ecto.Migration

  def change do
    create unique_index(:films, [:title])
  end
end
