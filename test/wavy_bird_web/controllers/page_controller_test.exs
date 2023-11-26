defmodule WavyBirdWeb.PageControllerTest do
  use WavyBirdWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200) =~
             "This site provides common tools used in a wide variety of tasks performed in a developer's workflow"
  end

  test "GET /web/sandbox", %{conn: conn} do
    conn = get(conn, ~p"/web/sandbox")

    assert html_response(conn, 200) =~
             "Used for testing HTTP request/response handling and clients"
  end

  test "GET /web/sandbox/http", %{conn: conn} do
    conn = get(conn, ~p"/web/sandbox/http")

    assert response(conn, 200)
  end
end
