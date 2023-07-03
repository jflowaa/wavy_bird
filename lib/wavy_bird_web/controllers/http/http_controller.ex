defmodule WavyBirdWeb.HttpController do
  use WavyBirdWeb, :controller

  def echo(conn, _params), do: render(conn, :echo)

  def status(conn, %{"status" => status}), do: conn |> put_status(String.to_integer(status)) |> render(:echo)
end
