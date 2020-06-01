import Config

config :demo, Demo.Repo,
  username: "demo",
  password: "demo",
  database: "demo",
  hostname: System.fetch_env!("DB_HOST"),
  pool_size: 10
