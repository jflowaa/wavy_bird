defmodule WavyBirdWeb.HnJobsLive.Index do
  use WavyBirdWeb, :live_view
  alias WavyBird.HnJobs.Client, as: HnJobsClient

  @impl true
  def mount(_params, _session, socket) do
    case HnJobsClient.get_latest_story() do
      {:ok, story} ->
        case HnJobsClient.get_jobs(Map.get(story, :item_id)) do
          {:ok, postings} ->
            {:ok,
             socket
             |> stream(:jobs, postings)
             |> assign(:story, story)
             |> assign(:stories, HnJobsClient.get_stories())}

          _ ->
            {:ok, socket |> stream(:jobs, []) |> assign(:stories, HnJobsClient.get_stories())}
        end

      _ ->
        {:ok, socket |> stream(:jobs, []) |> assign(:stories, HnJobsClient.get_stories())}
    end
  end

  @impl true
  def handle_event("set_story", payload, socket) do
    {:ok, story_id} = HnJobsClient.get_story_id(Map.get(payload, "story"))
    {:ok, jobs} = HnJobsClient.get_jobs(story_id)

    {:noreply,
     socket
     |> stream(:jobs, jobs, reset: true)
     |> assign(:story, %{:item_id => story_id, :title => Map.get(payload, "story")})}
  end

  @impl true
  def handle_event("filter", %{"tag" => tags, "exclusive" => exclusive}, socket) do
    filters = String.split(tags, ",") |> Enum.map(fn x -> String.trim(x) end)

    if Enum.count(filters) == 0 do
      {:ok, postings} = HnJobsClient.get_jobs(Map.get(Map.get(socket.assigns, :story), :item_id))

      {:noreply, stream(socket, :jobs, postings, reset: true)}
    else
      {:ok, postings} =
        HnJobsClient.get_filtered_jobs(
          Map.get(Map.get(socket.assigns, :story), :item_id),
          filters,
          exclusive
        )

      {:noreply, socket |> stream(:jobs, postings, reset: true)}
    end
  end
end
