defmodule WavyBirdWeb.ToolsLive.UuidComponent do
  use WavyBirdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={%{}} id="uuid-form" phx-target={@myself} phx-submit="generate">
        <.input
          type="select"
          name="version"
          options={["v1", "v3", "v4", "v5"]}
          value={if assigns[:version], do: assigns[:version], else: "v4"}
          phx-change="version"
        />
        <%= if assigns[:version] == "v3" or assigns[:version] == "v5" do %>
          <.input
            type="select"
            name="namespace"
            options={["DNS", "URL", "OID", "x500", "None"]}
            value="dns"
            phx-update="ignore"
            id="uuid-namespace"
          />
          <.input type="text" name="name" value="" placeholder="name" phx-update="ignore" />
        <% end %>
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
  def handle_event("version", payload, socket) do
    {:noreply,
     socket
     |> assign(:version, Map.get(payload, "version"))}
  end

  @impl true
  def handle_event("generate", payload, socket) do
    {:ok, result} =
      generate(
        Map.get(payload, "version"),
        Map.get(payload, "namespace"),
        Map.get(payload, "name"),
        Map.get(payload, "format")
      )

    {:noreply,
     socket
     |> assign(:version, Map.get(payload, "version"))
     |> assign(:result, result)}
  end

  defp generate(version, namespace, name, format) do
    case version do
      "v1" ->
        {:ok, UUID.uuid1(determine_format(format))}

      "v3" ->
        {:ok, UUID.uuid3(determine_namespace(namespace), name, determine_format(format))}

      "v4" ->
        {:ok, UUID.uuid4(determine_format(format))}

      "v5" ->
        {:ok, UUID.uuid5(determine_namespace(namespace), name, determine_format(format))}

      _ ->
        {:ok, ""}
    end
  end

  defp determine_namespace(namespace) do
    case if namespace, do: String.downcase(namespace), else: nil do
      "dns" -> :dns
      "url" -> :url
      "oid" -> :oid
      "x500" -> :x500
      _ -> nil
    end
  end

  defp determine_format(format) do
    case String.downcase(format) do
      "default" -> :default
      "hex" -> :hex
      "urn" -> :urn
      _ -> :default
    end
  end
end
