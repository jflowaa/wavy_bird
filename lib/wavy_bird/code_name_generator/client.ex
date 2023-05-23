defmodule WavyBird.CodeNameGenerator.Client do
  require Logger

  def generate() do
    GenServer.call(:code_name_generator_server, :generate)
  end
end
