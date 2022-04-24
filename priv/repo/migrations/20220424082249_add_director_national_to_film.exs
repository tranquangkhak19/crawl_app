defmodule Crawlapp.Repo.Migrations.AddDirectorNationalToFilm do
  use Ecto.Migration

  def change do
    alter table(:films) do
      add :director, :string
      add :national, :string
    end
  end
end
