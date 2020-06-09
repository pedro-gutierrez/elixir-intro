defmodule Demo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Demo.Repo,
      # Start the Telemetry supervisor
      DemoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Demo.PubSub},
      # Start the Endpoint (http/https)
      DemoWeb.Endpoint,
      # Start a worker by calling: Demo.Worker.start_link(arg)
      # {Demo.Worker, arg}

      # Start a cluster supervisor for node discovery
      # using libcluster and the configured Kubernetes strategy
      {Cluster.Supervisor,
       [Application.get_env(:libcluster, :topologies) || [], [name: Demo.ClusterSupervisor]]},

      # Start a local supervisor for all entries in our key value store
      {DynamicSupervisor, strategy: :one_for_one, max_restarts: 5000, max_seconds: 1, name: Demo.KvSupervisor},
      
      # Start a supervisor for load tests
      {DynamicSupervisor, strategy: :one_for_one, max_restarts: 5000, max_seconds: 1, name: Demo.LoadSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    pid = Supervisor.start_link(children, opts)

    path = Application.app_dir(:demo, "priv/repo/migrations")
    Ecto.Migrator.run(Demo.Repo, path, :up, all: true)
    pid
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
