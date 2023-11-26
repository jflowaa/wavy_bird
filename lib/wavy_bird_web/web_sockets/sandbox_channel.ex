defmodule WavyBirdWeb.WebSockets.SandboxChannel do
  use Phoenix.Channel

  def join("echo", _message, socket) do
    {:ok, socket}
  end

  def handle_in("echo", %{"body" => body}, socket) do
    broadcast!(socket, "message", %{body: body})
    {:noreply, socket}
  end
end
