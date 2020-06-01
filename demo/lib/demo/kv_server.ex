defmodule Demo.KvServer do
  @moduledoc """
  A GenServer that manages the lifecycle of a single 
  entry of our key value store
  """
  
  # The backend module to use for persistence.
  @backend Application.get_env(:demo, :backend, Demo.KvEntry)
  
  # The inactivity timeout after which we stop
  # the GenServer in order to free resources
  @ttl 5000

  use GenServer, restart: :transient
  require Logger

  @doc """
  Starts a supervised GenServer process for the given key
  This function is only to be called by a Supervisor 
  """
  def start_link(key) do
    GenServer.start_link(__MODULE__, key, name: {:global, key})
  end

  @impl true
  def init(key) do
    Logger.info("Pid #{inspect(self())} for #{key} is starting")
    
    # We continue the initialization of this GenServer 
    # in a handle_continue/2 callback. This is because the 
    # init/1 callback of a GenServer is actually a call
    # that blocks the supervisor. So any expensive operation,
    # such as reading from an external storage, must be 
    # done asynchronously
    {:ok, key, {:continue, :fetch}}
  end

  @impl true
  def handle_continue(:fetch, key) do
    # This is the first operation that will happen in this newly
    # created GenServer. We fetch the current value for our 
    # key from the underlying storage backend, and we use that
    # as the updated current state for this process. We also
    # setup the configured inactivity timeout value
    values = @backend.read(key)
    {:noreply, {key, values}, @ttl}   
  end

  @impl true
  def handle_call(:read, _, {_, []} = state) do
    # We got a synchronous read command, however our state doesn't have
    # any values yet. Assuming no other process is writing to 
    # our key (that would be the case in the absence of
    # network partitions, since we are registered globally),
    # this means there is no value yet for this key.
    #
    # We can safely return a not found response and stop this 
    # server
    {:stop, :normal, {:error, :not_found}, state}
  end

  def handle_call(:read, _, {_, [{_, value}|_]} = state) do
    # We got a synchronous read command and we have at least one versioned
    # value for our key. We pattern match, knowing that 
    # most recent versions are at the beginning of the list
    # and we return the value to the caller. 
    #
    # We also set the inactivity timeout, and continue
    # listening for new messages
    {:reply, {:ok, value}, state, @ttl}
  end

  def handle_call({:write, value}, _, {key, []=current_versions}) do
    # We got a synchronous write command, however we havent got any 
    # values yet. So we can safely write the first version for this key.
    # In order to do this, we use a private helper
    # that will handle the more general case.
    write(key, 1, value, current_versions)
  end
  
  def handle_call({:write, value}, _, {_, [{_, value}|_]}=state) do
    # We got a synchronous synchronous write command, but the value we are trying to write 
    # matches the last version seen for this command. 
    # Here we decide to ignore possible network partitions, and we save one 
    # write operation to the database.
    #
    # We keep the same state and configure the inactivity timeout
    {:reply, :ok, state, @ttl}
  end
  
  def handle_call({:write, value}, _, {key, [{version, _}|_] = current_versions}) do
    # We got a synchronous write command for a new value. We increment the last 
    # version we had and we write the new value using our private helper
    write(key, version+1, value, current_versions)
  end
  
  def handle_call(:delete, _, {_, []}=state) do
    # We got a synchronous delete command, however we have no values.
    # We assume this key didn't exist. We return a `not_found` term
    # and stop the process
    {:stop, :normal, {:error, :not_found}, state}
  end

  def handle_call(:delete, _, {key, _}=state) do
    # We got a synchronous delete command, and there are values to delete.
    # We call the backend, inform the caller, and stop this process.
    :ok = @backend.delete(key)
    {:stop, :normal, :ok, state}
  end

  @impl true
  def handle_info(:timeout, {key, _} = state) do
    # We got an out of band message from our inactivity timeout. 
    # This means we haven't received any messages for a while, so 
    # we can stop this process for now, and free up some resources. 
    #
    # The values in the backend for this key won't be touched.
    Logger.warn("Pid #{inspect(self())} for #{key} is stopping")
    {:stop, :normal, state}
  end

  # A reusable private helper that sends a versioned value to the backend
  # for the given key. This function handles conflicts 
  # and manages the lifecycle of our GenServer. 
  defp write(key, version, value, current_versions) do
    case @backend.write(key, version, value) do
      {:ok, _} ->
        # The new value was succesfully written. We return an 
        # `:ok` tuple to the caller process, and we update our new state, 
        # by preprending the new versio to the list of current versions.
        #
        # We also set the inactivity timeout
        {:reply, :ok, {key, [{version, value}|current_versions]}, @ttl}

      {:error, _} ->
        # An error occurred while writing the version to the database
        # We can do fine grained error checking by pattern matching on
        # the term returned by the backend, but for now
        # we assume we got a conflict. In case case, we stop the process
        # so that next read/write call to this key will 
        # be performed on a fresh process with the most up to date 
        # state from the backend
        {:stop, :normal, {:error, :conflict}, {key, current_versions}}
    end
  end
end
