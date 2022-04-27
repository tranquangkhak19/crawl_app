defmodule Crawlapp.Film do
  use Ecto.Schema
  import Ecto.Changeset

  schema "films" do
    field :title, :string
    field :link, :string
    field :full_series, :boolean
    field :episode_number, :integer
    field :thumnail, :string
    field :year, :integer
    field :director, :string
    field :national, :string
    field :category, :integer
  end


  def changeset(film, params) do
    film
    |> cast(params, [:title, :link, :full_series, :episode_number, :thumnail, :year, :director, :national, :category])
    |> validate_required([:title])
    |> unique_constraint(:title)

  end
end
