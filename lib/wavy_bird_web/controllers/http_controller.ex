defmodule WavyBirdWeb.HttpController do
  use WavyBirdWeb, :controller

  def echo(conn, _params), do: render(conn, :echo)

  def status(conn, %{"code" => code}), do: conn |> put_status(String.to_integer(code)) |> render(:echo)

  def delay(conn, %{"seconds" => seconds}) do
    Process.sleep(String.to_integer(seconds) * 1000)
    render(conn, :echo)
  end

  def set_cookie(conn,  %{"key" => key, "value" => value}) do
    conn |> put_resp_cookie(key, value) |> render(:echo)
  end

  def remove_cookie(conn,  %{"key" => key}) do
    conn |> delete_resp_cookie(key) |> render(:echo)
  end
end
