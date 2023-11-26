defmodule WavyBird.HnJobs.Scraper do
  use Quantum, otp_app: :wavy_bird
  alias WavyBird.HnJobs.HackerNewsApiClient, as: HnApiClient

  @database_root "dbs/hn_jobs"
  @story_database_path "#{@database_root}/stories.db"
  @create_stories_table_query "create table if not exists stories (id integer primary key, item_id integer, title text)"
  @insert_story_query "insert into stories (item_id, title) values ((?1), (?2))"
  @story_exists_query "select count(1) from stories where item_id = (?1)"
  @create_postings_table_query "create table if not exists postings (id integer primary key, item_id integer, timestamp integer, user text, content text, deleted boolean)"
  @posting_exists_query "select count(1) from postings where item_id = (?1)"
  @insert_posting_query "insert into postings (item_id, user, timestamp, content, deleted) values ((?1), (?2), (?3), (?4), (?5))"

  def run() do
    {:ok, conn} = Exqlite.Sqlite3.open(@story_database_path)

    Exqlite.Sqlite3.execute(conn, @create_stories_table_query)

    {:ok, insert_statement} = Exqlite.Sqlite3.prepare(conn, @insert_story_query)

    HnApiClient.get_who_is_hiring_user()
    |> elem(1)
    |> Map.get(:body)
    |> Map.get("submitted")
    |> Enum.take(5)
    |> Enum.each(fn x ->
      body =
        HnApiClient.get_item_by_id(x)
        |> elem(1)
        |> Map.get(:body)

      if String.starts_with?(Map.get(body, "title"), "Ask HN: Who is hiring?") do
        {:ok, exists_statement} = Exqlite.Sqlite3.prepare(conn, @story_exists_query)

        Exqlite.Sqlite3.bind(conn, exists_statement, [x])
        {:row, count} = Exqlite.Sqlite3.step(conn, exists_statement)

        if List.first(count) == 0 do
          Exqlite.Sqlite3.bind(conn, insert_statement, [x, Map.get(body, "title")])
          Exqlite.Sqlite3.step(conn, insert_statement)
        end

        spawn(fn -> process_story(body) end)
      end
    end)

    :ok
  end

  def process_story(story) do
    {:ok, conn} = Exqlite.Sqlite3.open("#{@database_root}/story_#{Map.get(story, "id")}.db")

    Exqlite.Sqlite3.execute(conn, @create_postings_table_query)

    {:ok, exists_statement} = Exqlite.Sqlite3.prepare(conn, @posting_exists_query)

    {:ok, insert_statement} = Exqlite.Sqlite3.prepare(conn, @insert_posting_query)

    Map.get(story, "kids")
    |> Enum.each(fn x ->
      Exqlite.Sqlite3.bind(conn, exists_statement, [x])
      {:row, count} = Exqlite.Sqlite3.step(conn, exists_statement)

      if List.first(count) == 0 do
        body = HnApiClient.get_item_by_id(x) |> elem(1) |> Map.get(:body)

        if not is_nil(body) do
          Exqlite.Sqlite3.bind(conn, insert_statement, [
            x,
            Map.get(body, "by"),
            Map.get(body, "time"),
            Map.get(body, "text"),
            Map.has_key?(body, "dead") || Map.has_key?(body, "deleted")
          ])

          Exqlite.Sqlite3.step(conn, insert_statement)
        end
      end
    end)
  end
end
