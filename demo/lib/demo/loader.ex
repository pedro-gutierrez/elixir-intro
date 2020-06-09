defmodule Demo.Loader do
  @moduledoc """
  A simple load generator
  """

  @supervisor Demo.LoadSupervisor
  @client Demo.LoadClient
    
  def load(0), do: :ok

  def load(count) do
    {:ok, _} = DynamicSupervisor.start_child(@supervisor, @client)
    load(count-1)
  end
end
