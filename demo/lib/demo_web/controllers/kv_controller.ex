defmodule DemoWeb.KvController do
  use DemoWeb, :controller

  @api Demo.Kv

  def get(conn, %{"key" => key}) do
    case @api.get(key) do
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
    case @api.put(key, value) do
      :ok ->
        conn
        |> put_status(200)
        |> json(%{})

      {:error, :conflict} ->
        conn
        |> put_status(409)
        |> json(%{})
    end
  end

  def delete(conn, %{"key" => key}) do
    case @api.delete(key) do
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
