defmodule Demo.Kv do
  @moduledoc """
  A simple KV store
  """

  @ttl 5000

  use GenServer, restart: :transient
  require Logger

  @doc """
  Get the value for the specified key
  """
  def get(key) do
    case :global.whereis_name(key) do
      :undefined ->
        {:error, :not_found}

      pid ->
        {:ok, _} = GenServer.call(pid, :get)
    end
  end

  @doc """
  Insert or update the value for a given key
  """
  def put(key, value) do
    case :global.whereis_name(key) do
      :undefined ->
        {:ok, _} = DynamicSupervisor.start_child(Demo.KvSupervisor, {__MODULE__, [key, value]})
        :ok

      pid ->
        :ok = GenServer.call(pid, {:put, value})
    end
  end

  def delete(key) do
    case :global.whereis_name(key) do
      :undefined ->
        {:error, :not_found}

      pid ->
        :ok = GenServer.call(pid, :delete)
    end
  end

  @doc """
  Starts a supervised GenServer process for the given key
  This function is only to be called by a Supervisor 
  """
  def start_link([key, value]) do
    GenServer.start_link(__MODULE__, [key, value], name: {:global, key})
  end

  @impl true
  def init([key, value]) do
    Logger.info("process #{inspect(self())} for #{key} with value #{value} is starting")
    {:ok, {key, value}, @ttl}
  end

  @impl true
  def handle_call(:get, _, {_, value} = state) do
    {:reply, {:ok, value}, state, @ttl}
  end

  def handle_call({:put, value}, _, {key, _}) do
    {:reply, :ok, {key, value}, @ttl}
  end

  def handle_call(:delete, _, state) do
    {:stop, :normal, :ok, state}
  end

  @impl true
  def handle_info(:timeout, {key, value} = state) do
    Logger.warn("process #{inspect(self())} for #{key} with value #{value} is expiring")
    {:stop, :normal, state}
  end
end
