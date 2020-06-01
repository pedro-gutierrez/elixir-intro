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
    key
    |> pid()
    |> call(:read)
  end

  @doc """
  Insert or update the value for a given key
  """
  def put(key, value) do
    key
    |> pid()
    |> call({:write, value})
  end
  
  @doc """
  Delete the given key from the store
  """
  def delete(key) do
    key
    |> pid()
    |> call(:delete)
  end
  
  # Find a process for the given key, and send it the given
  # command. If the process is not registered, then start it
  # first
  defp pid(key) do
    case DynamicSupervisor.start_child(Demo.KvSupervisor, {__MODULE__, key}) do
      {:ok, pid} ->
        pid

      {:error, {:already_started, pid}} ->
        pid
    end
  end

  defp call(pid, cmd) do
    GenServer.call(pid, cmd)
  end

  @doc """
  Starts a supervised GenServer process for the given key
  This function is only to be called by a Supervisor 
  """
  def start_link(key) do
    GenServer.start_link(__MODULE__, key, name: {:global, key})
  end

  @backend Application.get_env(:demo, :backend, Demo.KvEntry)

  @impl true
  def init(key) do
    Logger.info("Pid #{inspect(self())} for #{key} is starting")
    {:ok, key, {:continue, :fetch}}
  end

  @impl true
  def handle_continue(:fetch, key) do
    values = @backend.read(key)
    {:noreply, {key, values}, @ttl}   
  end

  @impl true
  def handle_call(:read, _, {_, []} = state) do
    {:stop, :normal, {:error, :not_found}, state}
  end

  def handle_call(:read, _, {_, [{_, value}|_]} = state) do
    {:reply, {:ok, value}, state, @ttl}
  end

  def handle_call({:write, value}, _, {key, []}) do
    {:ok, _} = @backend.write(key, 1, value)
    {:reply, :ok, {key, [{1, value}]}, @ttl}
  end
  
  def handle_call({:write, value}, _, {_, [{_, value}|_]}=state) do
    {:reply, :ok, state, @ttl}
  end
  
  def handle_call({:write, value}, _, {key, [{version, _}|_] = versions}=state) do
    next_version = version+1
    case @backend.write(key, next_version, value) do
      {:ok, _} ->
        {:reply, :ok, {key, [{next_version, value}|versions]}, @ttl}

      {:error, _} ->
        {:stop, :normal, {:error, :conflict}, state}
    end
  end
  
  def handle_call(:delete, _, {_, []}=state) do
    {:stop, :normal, {:error, :not_found}, state}
  end

  def handle_call(:delete, _, {key, _}=state) do
    :ok = @backend.delete(key)
    {:stop, :normal, :ok, state}
  end

  @impl true
  def handle_info(:timeout, {key, _} = state) do
    Logger.warn("Pid #{inspect(self())} for #{key} is stopping")
    {:stop, :normal, state}
  end
end
