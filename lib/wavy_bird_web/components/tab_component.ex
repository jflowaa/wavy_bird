defmodule WavyBirdWeb.Components do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  def tabs(assigns) do
    assigns =
      assigns
      |> assign_new(:active_class, fn -> "border-secondary-500 text-secondary-600" end)
      |> assign_new(:inactive_class, fn ->
        "border-transparent text-neutral-500 hover:text-neutral-700 hover:border-neutral-300"
      end)
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:tab, fn -> [] end)

    ~H"""
    <div id={@id} class={@class}>
      <div class="sm:hidden">
        <label for={"#{@id}-mobile"} class="sr-only">Select a tab</label>
        <select
          id={"#{@id}-mobile"}
          name="tabs"
          phx-change={JS.dispatch("js:tab-selected", detail: %{id: "#{@id}-mobile"})}
          class="block w-full pl-3 pr-10 py-2 text-base border-neutral-300 focus:outline-none focus:ring-secondary-500 focus:border-secondary-500 sm:text-sm rounded-md"
        >
          <%= for {tab, i} <- Enum.with_index(@tab) do %>
            <option value={"#{@id}-#{i}"}><%= tab.title %></option>
          <% end %>
        </select>
      </div>
      <div class="hidden sm:block mb-5 flex list-none flex-row flex-wrap border-b-0 pl-0">
        <div class="border-b border-neutral-200">
          <nav class="-mb-px flex space-x-8" aria-label="Tabs">
            <%= for {tab, i} <- Enum.with_index(@tab), tab_id = "#{@id}-#{i}" do %>
              <%= if tab[:current] do %>
                <.link
                  id={tab_id}
                  phx-click={show_tab(@id, i, @active_class, @inactive_class)}
                  class={"flex-auto text-center py-4 px-1 border-b-2 font-medium text-sm #{@active_class }"}
                  aria-current="page"
                >
                  <%= tab.title %>
                </.link>
              <% else %>
                <.link
                  id={tab_id}
                  phx-click={show_tab(@id, i, @active_class, @inactive_class)}
                  class={"flex-auto text-center py-4 px-1 border-b-2 font-medium text-sm #{@inactive_class}"}
                >
                  <%= tab.title %>
                </.link>
              <% end %>
            <% end %>
          </nav>
        </div>
      </div>
      <%= for {tab, i} <- Enum.with_index(@tab) do %>
        <div id={"#{@id}-#{i}-content"} class={if !tab[:current], do: "hidden"} data-tab-content>
          <%= render_slot(tab) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp show_tab(js \\ %JS{}, id, tab_index, active_class, inactive_class) do
    tab_id = "#{id}-#{tab_index}"

    js
    |> JS.add_class("hidden", to: "##{id} [data-tab-content]")
    |> JS.remove_class("hidden", to: "##{tab_id}-content")
    |> JS.remove_class(active_class, to: "##{id} nav a")
    |> JS.add_class(inactive_class, to: "##{id} nav a")
    |> JS.remove_class(inactive_class, to: "##{tab_id}")
    |> JS.add_class(active_class, to: "##{tab_id}")
    |> JS.remove_attribute("selected", to: "##{id}-mobile option")
    |> JS.set_attribute({"selected", ""}, to: "##{id}-mobile option[value='#{tab_id}'")
  end
end
