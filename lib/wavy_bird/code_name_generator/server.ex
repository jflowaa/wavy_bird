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
    words =
      File.stream!("data/words.txt")
      |> Stream.map(&String.trim_trailing/1)

    {:ok, words}
  end

  def handle_call({:generate, number_of_words}, _from, state) do
    {:reply,
     {:ok,
      Enum.map(1..1, fn _ ->
        state
        |> Enum.shuffle()
        |> Enum.take(elem(Integer.parse(number_of_words), 0))
        |> Enum.map(fn x -> Macro.camelize(x) end)
        |> Enum.join(" ")
      end)}, state}
  end
end
