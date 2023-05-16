defmodule WavyBirdWeb.ToolsLive.CodeNameGeneratorComponent do
  use WavyBirdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={%{}} id="code-name-form" phx-target={@myself} phx-submit="generate">
        <.input type="number" name="number" value="2" max="4" min="1" />
        <:actions>
          <.button phx-disable-with="Generating...">Generate</.button>
        </:actions>
      </.simple_form>
      <%= if assigns[:result] do %>
        <.header>Code Names</.header>

        <%= for code_name <- @result do %>
          <div class="rounded-2xl bg-primary-50 p-6 overflow-x-auto">
            <code><%= code_name %></code>
          </div>
          <br />
        <% end %>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("generate", %{"number" => number}, socket) do
    {:ok, result} = WavyBird.CodeNameGenerator.Client.generate(number)

    {:noreply,
     socket
     |> assign(:result, result)}
  end
end
