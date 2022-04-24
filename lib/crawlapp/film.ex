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
  end


  def changeset(struct, _params \\ %{}) do
    struct
    |> validate_required([:title])
  end
end
