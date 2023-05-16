defmodule WavyBird.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WavyBirdWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: WavyBird.PubSub},
      # Start Finch
      {Finch, name: WavyBird.Finch},
      # Start the Endpoint (http/https)
      WavyBirdWeb.Endpoint,
      # Start a worker by calling: WavyBird.Worker.start_link(arg)
      # {WavyBird.Worker, arg}
      WavyBird.HnJobs.Scraper,
      WavyBird.HnJobs.Server,
      WavyBird.CodeNameGenerator.Server
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WavyBird.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WavyBirdWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
