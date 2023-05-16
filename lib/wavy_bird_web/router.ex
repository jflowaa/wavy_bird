defmodule WavyBirdWeb.Router do
  use WavyBirdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WavyBirdWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WavyBirdWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/tools", ToolsLive.Index, :index
    live "/hn/jobs", HnJobsLive.Index, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", WavyBirdWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:wavy_bird, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
