defmodule WavyBird.CodeNameGenerator.Server do
  use GenServer, restart: :transient
  require Logger

  def start_link(opts) do
    case GenServer.start_link(__MODULE__, opts, name: :code_name_generator_server) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, _}} ->
        :ignore
    end
  end

  def init(_) do
    :ets.new(:words_table, [:set, :private, :named_table])

    File.stream!("data/words.txt")
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.with_index(1)
    |> Stream.each(fn x ->
      :ets.insert(:words_table, {elem(x, 1), elem(x, 0)})
    end)
    |> Stream.run()

    {:ok, Keyword.get(:ets.info(:words_table), :size)}
  end

  def handle_call({:generate, number_of_words}, _from, state) do
    {:reply,
     {:ok,
      Enum.map(1..6, fn _ ->
        Enum.map(1..elem(Integer.parse(number_of_words), 0), fn _ ->
          :ets.lookup(:words_table, Enum.random(1..state))
          |> hd
          |> elem(1)
          |> Macro.camelize()
        end)
        |> Enum.join(" ")
      end)}, state}
  end
end
