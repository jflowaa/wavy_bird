defmodule WavyBirdWeb.WebSandboxLive.Http do
  use WavyBirdWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
