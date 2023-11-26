defmodule WavyBirdWeb.WebSockets.SandboxSocket do
  use Phoenix.Socket

  channel "/echo", WavyBirdWeb.WebSockets.SandboxChannel
end
