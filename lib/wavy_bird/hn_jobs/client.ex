defmodule WavyBird.HnJobs.Client do
  require Logger

  def get_latest_story() do
    GenServer.call(:hn_server, :get_latest_story)
  end

  def get_stories() do
    GenServer.call(:hn_server, :get_stories)
  end

  def get_story_id(story_title) do
    GenServer.call(:hn_server, {:get_story_id, story_title})
  end

  def get_jobs(story_id) do
    GenServer.call(:hn_server, {:get_jobs, story_id})
  end

  def get_filtered_jobs(story_id, filters, is_exclusive) do
    GenServer.call(:hn_server, {:get_jobs, story_id, filters, is_exclusive})
  end
end
