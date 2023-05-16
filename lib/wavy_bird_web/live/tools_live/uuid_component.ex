defmodule WavyBirdWeb.ToolsLive.UuidComponent do
  use WavyBirdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={%{}} id="uuid-form" phx-target={@myself} phx-submit="generate">
        <.input type="select" name="version" options={["v1", "v2", "v3", "v4", "v5"]} value="v4" />
        <.input
          type="select"
          name="format"
          options={["Default", "Hex", "URN"]}
          value="default"
          phx-update="ignore"
        />
        <:actions>
          <.button phx-disable-with="Generating...">Generate</.button>
        </:actions>
      </.simple_form>
      <%= if assigns[:result] do %>
        <.header>Result</.header>
        <code><%= @result %></code>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("generate", payload, socket) do
    {:ok, result} = generate(Map.get(payload, "version"), Map.get(payload, "format"))

    {:noreply,
     socket
     |> assign(:result, result)}
  end

  defp generate(version, _format) do
    case version do
      "v1" ->
        {:ok, UUID.uuid1()}

      "v2" ->
        {:ok, ""}

      "v3" ->
        {:ok, UUID.uuid3(:dns, "cat")}

      "v4" ->
        {:ok, UUID.uuid4()}

      "v5" ->
        {:ok, UUID.uuid5(:dns, "cat")}

      _ ->
        {:ok, ""}
    end
  end
end
