defmodule Crawlapp.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :category, :string
  end


  def changeset(category, params) do
    category
    |> cast(params, [:category])
    |> validate_required([:category])
    |> unique_constraint(:category)
  end
end
