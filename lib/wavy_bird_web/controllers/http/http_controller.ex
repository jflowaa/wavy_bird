defmodule WavyBirdWeb.HttpController do
  use WavyBirdWeb, :controller

  def echo(conn, _params), do: render(conn, :echo)

  def status(conn, %{"status" => status}), do: conn |> put_status(String.to_integer(status)) |> render(:echo)

  def delay(conn, %{"seconds" => seconds}) do
    IO.inspect(conn)
    Process.sleep(String.to_integer(seconds) * 1000)
    render(conn, :echo)
  end
end
