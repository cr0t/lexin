defmodule Lexin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_backend(Sentry.LoggerBackend)

    children = [
      # Start the Telemetry supervisor
      LexinWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Lexin.PubSub},
      # Start a worker by calling: Lexin.Worker.start_link(arg)
      Lexin.Dictionary.Worker,
      # Start the Endpoint (http/https)
      LexinWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lexin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LexinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
