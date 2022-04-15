import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :crawlapp, Crawlapp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "crawlapp_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crawlapp, CrawlappWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "9Osuu4L+d9z2vvWNizi+v038IE0ntYNRQd9AaCkTJLDQ9uQ0UM9P8ewuUsf5/BYz",
  server: false

# In test we don't send emails.
config :crawlapp, Crawlapp.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
