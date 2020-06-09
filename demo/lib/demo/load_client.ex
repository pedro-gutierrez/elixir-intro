defmodule Demo.LoadClient do
  @moduledoc """
  A gen server that acts as a client to our Key Value store.
  It fetches its configuration from the `Demo.Loader` key 
  of the `:demo` application environment

  Then it simply starts, writes a random key and value,
  and terminates normally.
  """

  @settings Application.get_env(:demo, Demo.Loader, [])
  
  use GenServer, restart: :permanent
  require Logger

  @doc """
  Starts a new supervised client
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, @settings)
  end

  @impl true
  def init(settings) do
    Logger.info("(Re)starting load generator client...")
    {:ok, settings, settings[:sleep]}
  end

  @impl true
  def handle_info(:timeout, settings) do
    Logger.info("Writing key...")
    {:ok, %HTTPoison.Response{status_code: 200}} = 
      HTTPoison.put("#{settings[:target]}/keys/#{UUID.uuid4()}/#{UUID.uuid4()}")
    {:noreply, settings, settings[:sleep]}
  end

end
