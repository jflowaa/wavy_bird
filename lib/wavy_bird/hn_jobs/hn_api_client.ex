defmodule WavyBird.HnJobs.HackerNewsApiClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://hacker-news.firebaseio.com/v0/"
  plug Tesla.Middleware.JSON
  adapter(Tesla.Adapter.Hackney, recv_timeout: 10_000)

  def get_item_by_id(item_id) do
    get("item/#{item_id}.json")
  end

  def get_who_is_hiring_user() do
    get("user/whoishiring.json")
  end
end
