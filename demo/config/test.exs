use Mix.Config

# Configure your database
config :demo, Demo.Repo,
  username: "demo",
  password: "demo",
  database: "demo_test",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox

#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# config :demo, Demo.Repo,
#  username: "postgres",
#  password: "postgres",
#  database: "demo_test#{System.get_env("MIX_TEST_PARTITION")}",
#  hostname: "localhost",
#  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :demo, DemoWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
