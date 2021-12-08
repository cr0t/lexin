# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configure i18n and supported locales
config :lexin, LexinWeb.Gettext,
  default_locale: "sv",
  locales: ~w(en ru sv)

# Configures the endpoint
config :lexin, LexinWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: LexinWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Lexin.PubSub,
  live_view: [signing_salt: "x+eN2Pcb"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.13.2",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Tesla to use recommended adapter
config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 10_000]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
