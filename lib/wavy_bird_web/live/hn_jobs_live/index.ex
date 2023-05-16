defmodule WavyBirdWeb.HnJobsLive.Index do
  use WavyBirdWeb, :live_view
  alias WavyBird.HnJobs.Client, as: HnJobsClient

  @impl true
  def mount(_params, _session, socket) do
    case HnJobsClient.get_latest_story() do
      {:ok, story} ->
        case HnJobsClient.get_jobs(Map.get(story, :item_id)) do
          {:ok, postings} ->
            {:ok, socket |> stream(:jobs, postings) |> assign(:story, story)}

          _ ->
            {:ok, socket |> stream(:jobs, [])}
        end

      _ ->
        {:ok, socket |> stream(:jobs, [])}
    end
  end

  @impl true
  def handle_event("filter", %{"tag" => _}, socket) do
    {:noreply, socket |> put_flash(:error, "Not supported")}

    # filters = String.split(tags)

    # if Enum.count(filters) == 0 do
    #   {:ok, postings} =
    #     HnJobsClient.get_jobs(Map.get(Map.get(socket.assigns, :story), :item_id))

    #   {:noreply, stream(socket, :jobs, postings, reset: true)}
    # else
    #   {:ok, postings} =
    #     HnJobsClient.get_filtered_jobs(
    #       Map.get(Map.get(socket.assigns, :story), :item_id),
    #       filters
    #     )

    #   {:noreply, socket |> stream(:jobs, postings, reset: true)}
    # end
  end
end
