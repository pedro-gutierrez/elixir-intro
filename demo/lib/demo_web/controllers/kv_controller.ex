defmodule DemoWeb.KvController do
  use DemoWeb, :controller

  def get(conn, %{"key" => key}) do
    case Demo.Kv.get(key) do
      {:ok, value} ->
        conn
        |> put_status(200)
        |> json(%{key => value})

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{})
    end
  end

  def put(conn, %{"key" => key, "value" => value}) do
    case Demo.Kv.put(key, value) do
      :ok ->
        conn
        |> put_status(200)
        |> json(%{})

      _ ->
        conn
        |> put_status(500)
        |> json(%{})
    end
  end

  def delete(conn, %{"key" => key}) do
    case Demo.Kv.delete(key) do
      :ok ->
        conn
        |> put_status(200)
        |> json(%{})

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{})
    end
  end
end
