defmodule WavyBird.CodeNameGenerator.Client do
  require Logger

  def generate(number_of_words) do
    GenServer.call(:code_name_generator_server, {:generate, number_of_words})
  end
end
