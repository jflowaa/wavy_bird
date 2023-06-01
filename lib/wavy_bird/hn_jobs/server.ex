defmodule WavyBird.HnJobs.Server do
  use GenServer, restart: :transient
  require Logger

  @database_root "dbs/hn_jobs"
  @story_database_path "#{@database_root}/stories.db"
  @latest_story_query "select item_id, title from stories order by item_id desc limit 1"
  @top_stories_query "select item_id, title from stories order by item_id desc limit 10"
  @get_story_id_by_title_query "select item_id from stories where title = (?1)"
  @all_postings_query "select * from postings"
  @false_string "false"
  @filter_postings_query "select * from postings where "

  def start_link(opts) do
    case GenServer.start_link(__MODULE__, opts, name: :hn_server) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, _}} ->
        :ignore
    end
  end

  def init(_) do
    File.mkdir_p(@database_root)
    {:ok, {}}
  end

  def handle_call(:get_latest_story, _from, state) do
    case Exqlite.Sqlite3.open(@story_database_path) do
      {:ok, conn} ->
        case Exqlite.Sqlite3.prepare(conn, @latest_story_query) do
          {:ok, statement} ->
            case Exqlite.Sqlite3.step(conn, statement) do
              {:row, story} ->
                {:reply, {:ok, %{:item_id => Enum.at(story, 0), :title => Enum.at(story, 1)}},
                 state}

              {:error, error} ->
                {:reply, {:error, error}, state}
            end

          {:error, value} ->
            {:reply, {:error, value}, state}
        end

      {:error, value} ->
        {:reply, {:error, value}, state}
    end
  end

  def handle_call(:get_stories, _from, state) do
    case Exqlite.Sqlite3.open(@story_database_path) do
      {:ok, conn} ->
        case Exqlite.Sqlite3.prepare(conn, @top_stories_query) do
          {:ok, statement} ->
            {:reply,
             {:ok,
              Stream.iterate(Exqlite.Sqlite3.step(conn, statement), fn _ ->
                Exqlite.Sqlite3.step(conn, statement)
              end)
              |> Stream.take_while(fn x -> x != :done and elem(x, 0) == :row end)
              |> Stream.map(fn x ->
                record = elem(x, 1)

                %{
                  :item_id => Enum.at(record, 0),
                  :title => Enum.at(record, 1)
                }
              end)
              |> Enum.to_list()}, state}

          {:error, error} ->
            {:reply, {:error, error}, state}
        end

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  def handle_call({:get_story_id, story_title}, _from, state) do
    case Exqlite.Sqlite3.open(@story_database_path) do
      {:ok, conn} ->
        case Exqlite.Sqlite3.prepare(conn, @get_story_id_by_title_query) do
          {:ok, statement} ->
            Exqlite.Sqlite3.bind(conn, statement, [story_title])

            case Exqlite.Sqlite3.step(conn, statement) do
              {:row, item_id} ->
                {:reply, {:ok, item_id |> List.first()}, state}

              {:error, error} ->
                {:reply, {:error, error}, state}
            end

          {:error, error} ->
            {:reply, {:error, error}, state}
        end

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  def handle_call({:get_jobs, story_id}, _from, state) do
    case Exqlite.Sqlite3.open("#{@database_root}/story_#{story_id}.db") do
      {:ok, conn} ->
        case Exqlite.Sqlite3.prepare(conn, @all_postings_query) do
          {:ok, statement} ->
            {:reply,
             {:ok,
              Stream.iterate(Exqlite.Sqlite3.step(conn, statement), fn _ ->
                Exqlite.Sqlite3.step(conn, statement)
              end)
              |> Stream.take_while(fn x -> x != :done and elem(x, 0) == :row end)
              |> Stream.map(fn x ->
                record = elem(x, 1)

                %{
                  :id => Enum.at(record, 0),
                  :item_id => Enum.at(record, 1),
                  :timestamp => Enum.at(record, 2),
                  :user => Enum.at(record, 3),
                  :text => Enum.at(record, 4),
                  :deleted => Enum.at(record, 5)
                }
              end)
              |> Stream.filter(fn x -> Map.get(x, :deleted) == @false_string end)}, state}

          {:error, error} ->
            {:reply, {:error, error}, state}
        end

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  def handle_call({:get_jobs, story_id, filters, is_exclusive}, _from, state) do
    {:ok, conn} = Exqlite.Basic.open("#{@database_root}/story_#{story_id}.db")
    Exqlite.Basic.enable_load_extension(conn)
    Exqlite.Basic.load_extension(conn, ExSqlean.path_for("re"))

    predicate =
      filters
      |> Enum.with_index(1)
      |> Enum.map(fn x -> "regexp_like(upper(content), upper((?#{elem(x, 1)})))" end)
      |> Enum.join(if is_exclusive, do: " and ", else: " or ")

    IO.inspect(@filter_postings_query <> predicate)
    IO.inspect(filters)

    {:ok, _, %{rows: rows}, _} =
      Exqlite.Basic.exec(conn, @filter_postings_query <> predicate, filters)

    IO.inspect(rows)

    {:reply,
     {:ok,
      Stream.map(rows, fn x ->
        %{
          :id => Enum.at(x, 0),
          :item_id => Enum.at(x, 1),
          :timestamp => Enum.at(x, 2),
          :user => Enum.at(x, 3),
          :text => Enum.at(x, 4),
          :deleted => Enum.at(x, 5)
        }
      end)}, state}
  end
end
