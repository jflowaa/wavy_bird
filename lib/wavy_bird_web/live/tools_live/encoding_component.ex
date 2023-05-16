defmodule WavyBirdWeb.ToolsLive.EncodingComponent do
  use WavyBirdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={%{}} id="encoding-form" phx-target={@myself} phx-change="convert">
        <.input
          type="select"
          name="operation"
          options={["Encode", "Decode"]}
          value={if assigns[:operation], do: @operation, else: "Encode"}
        />
        <.input
          type="select"
          name="scheme"
          options={["Base16", "Base32", "Base64"]}
          value={if assigns[:scheme], do: @scheme, else: "Base64"}
        />
        <.input type="textarea" name="target" value={if assigns[:target], do: @target, else: ""} />
      </.simple_form>
      <%= if assigns[:result] do %>
        <.header>Result</.header>
        <code><%= @result %></code>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("convert", payload, socket) do
    if Enum.any?(Map.get(payload, "_target"), fn x -> x == "operation" end) do
      {:noreply,
       socket
       |> assign(:result, nil)
       |> assign(:target, nil)
       |> assign(:scheme, nil)
       |> assign(:operation, Map.get(payload, "operation"))}
    else
      result =
        cond do
          String.starts_with?(Map.get(payload, "scheme"), "Base") ->
            base(
              Map.get(payload, "scheme"),
              Map.get(payload, "operation"),
              Map.get(payload, "target")
            )

          true ->
            {:ok, nil}
        end

      case result do
        {:ok, value} ->
          jason_encode = Jason.encode_to_iodata(value)

          {:noreply,
           socket
           |> assign(
             :result,
             if(elem(jason_encode, 0) == :ok, do: value, else: nil)
           )
           |> assign(:target, Map.get(payload, "target"))
           |> assign(:scheme, Map.get(payload, "scheme"))}

        _ ->
          {:noreply,
           socket |> assign(:result, nil) |> assign(:target, Map.get(payload, "target"))}
      end
    end
  end

  defp base(scheme, operation, target) do
    cond do
      scheme == "Base16" and operation == "Encode" ->
        {:ok, Base.encode16(target)}

      scheme == "Base32" and operation == "Encode" ->
        {:ok, Base.encode32(target)}

      scheme == "Base64" and operation == "Encode" ->
        {:ok, Base.encode64(target)}

      scheme == "Base16" and operation == "Decode" ->
        Base.decode16(target)

      scheme == "Base32" and operation == "Decode" ->
        Base.decode32(target)

      scheme == "Base64" and operation == "Decode" ->
        Base.decode64(target)

      true ->
        {:ok, ""}
    end
  end
end
