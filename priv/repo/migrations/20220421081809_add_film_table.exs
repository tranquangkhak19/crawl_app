defmodule Crawlapp.Repo.Migrations.AddFilmTable do
  use Ecto.Migration

  def change do
    create table(:films) do
      add :title, :string
      add :link, :string
      add :full_series, :boolean
      add :episode_number, :integer
      add :thumnail, :string
      add :year, :integer
    end
  end
end
