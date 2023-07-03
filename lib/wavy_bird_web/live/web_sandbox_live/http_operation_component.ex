defmodule WavyBirdWeb.WebSandboxLive.HttpOperationComponent do
  use WavyBirdWeb, :live_component

  @impl true
  def handle_event("send", payload, socket) do
    IO.inspect(payload)
    {:noreply, socket}
  end
end
