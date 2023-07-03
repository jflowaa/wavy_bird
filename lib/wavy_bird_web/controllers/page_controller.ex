defmodule WavyBirdWeb.PageController do
  use WavyBirdWeb, :controller
  def home(conn, _params) do
    render(conn, :home)
  end

  def web_sandbox(conn, _params) do
    render(conn, :web_sandbox)
  end
end
