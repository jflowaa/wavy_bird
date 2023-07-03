defmodule WavyBirdWeb.PageController do
  use WavyBirdWeb, :controller
  def home(conn, _params) do
    render(conn, :home)
  end

  def web_sandbox(conn, _params) do
    render(conn, :web_sandbox)
  end

  def web_http_sandbox(conn, _params) do
    render(conn, :http_redoc)
  end
end
