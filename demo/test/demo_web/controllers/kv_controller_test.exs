defmodule DemoWeb.KvControllerTest do
  use DemoWeb.ConnCase

  test "stores, reads and deletes keys", %{conn: conn} do
    conn =
      conn
      |> delete("/keys/a")
      |> put("/keys/a/1")

    assert json_response(conn, 200) == %{}

    conn = get(conn, "/keys/a")
    assert json_response(conn, 200) == %{"a" => "1"}

    conn =
      conn
      |> delete("/keys/a")
      |> get("/keys/a")

    assert json_response(conn, 404) == %{}
  end
end
