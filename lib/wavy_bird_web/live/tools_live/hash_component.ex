defmodule WavyBirdWeb.ToolsLive.HashComponent do
  use WavyBirdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={%{}} id="hash-form" phx-target={@myself} phx-submit="hash">
        <.input
          type="select"
          name="function"
          options={["MD5", "SHA1", "SHA256", "SHA512", "BLAKE2"]}
          value="MD5"
          phx-update="ignore"
        />
        <.input type="textarea" name="target" value={if assigns[:target], do: @target, else: ""} />
        <:actions>
          <.button phx-disable-with="Hashing...">Hash</.button>
        </:actions>
      </.simple_form>
      <%= if assigns[:result] do %>
        <.header>Result</.header>
        <code><%= @result %></code>
        <p class="text-sm ...">Base16 Encoded</p>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("hash", payload, socket) do
    result = hash(Map.get(payload, "function"), Map.get(payload, "target"))

    {:noreply,
     socket
     |> assign(:target, Map.get(payload, "target"))
     |> assign(:result, result |> Base.encode16(case: :lower))}
  end

  defp hash(function, target) do
    case String.downcase(function) do
      "md5" -> :crypto.hash(:md5, target)
      "sha1" -> :crypto.hash(:sha, target)
      "sha256" -> :crypto.hash(:sha256, target)
      "sha512" -> :crypto.hash(:sha512, target)
      "blake2" -> :crypto.hash(:blake2b, target)
      _ -> :crypto.hash(:md5, target)
    end
  end
end
