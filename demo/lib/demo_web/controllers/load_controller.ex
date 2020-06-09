defmodule DemoWeb.LoadController do
  use DemoWeb, :controller

  def load(conn, %{"count" => count}) do

    {count, ""} = Integer.parse(count)
    :ok = Demo.Loader.load(count)

    conn
    |> put_status(200)
    |> json(%{})
  end
end
