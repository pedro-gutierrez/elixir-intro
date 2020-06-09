defmodule Demo.Kv do
  @moduledoc """
  A simple KV store
  """

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

  @server_module Demo.KvServer
  
  # Find a process for the given key, and send it the given
  # command. If the process is not registered, then start it
  # first
  defp pid(key) do
    case DynamicSupervisor.start_child(Demo.KvSupervisor, {@server_module, key}) do
      {:ok, pid} ->
        pid

      {:error, {:already_started, pid}} ->
        pid
    end
  end

  defp call(pid, cmd) do
    GenServer.call(pid, cmd)
  end
end
