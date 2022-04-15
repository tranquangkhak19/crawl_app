defmodule Crawlapp.Repo do
  use Ecto.Repo,
    otp_app: :crawlapp,
    adapter: Ecto.Adapters.Postgres
end
