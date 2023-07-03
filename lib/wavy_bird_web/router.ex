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
    get "/web/sandbox", PageController, :web_sandbox
    live "/tools", ToolsLive.Index
    live "/hn/jobs", HnJobsLive.Index
    live "/web/sandbox/http", WebSandboxLive.Http
    live "/web/sandbox/websocket", WebSandboxLive.Websocket
  end

  scope "/api", WavyBirdWeb do
    pipe_through :api

    get "/get", HttpController, :echo
    post "/post", HttpController, :echo
    put "/put", HttpController, :echo
    patch "/patch", HttpController, :echo
    delete "/delete", HttpController, :echo
    head "/head", HttpController, :echo

    get "/status/:status", HttpController, :status
    post "/status/:status", HttpController, :status
    put "/status/:status", HttpController, :status
    patch "/status/:status", HttpController, :status
    delete "/status/:status", HttpController, :status
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:wavy_bird, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
