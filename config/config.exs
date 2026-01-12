# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :sentry,
  environment_name: Mix.env()

# Configures the endpoint
config :lexin, LexinWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: LexinWeb.ErrorHTML, json: LexinWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Lexin.PubSub,
  live_view: [signing_salt: "x+eN2Pcb"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.27.2",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  css: [
    args: ~w(css/app.css --bundle --outdir=../priv/static/assets/),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  backends: [:console, Sentry.LoggerBackend]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure i18n and supported locales
config :lexin, LexinWeb.Gettext,
  default_locale: "sv",
  locales: ~w(en ru sv)

# For external links we need to provide prefixes
config :lexin, :external_audio_url_prefix, "http://lexin.nada.kth.se/sound/"

config :lexin, :external_video_url_prefix, "http://lexin.nada.kth.se/lang/lexinanim/"

config :lexin,
       :external_picture_url_prefix,
       "https://bildtema.isof.se/bildetema/bildetema-html5/bildetema.html?version=swedish"

config :lexin, :app_version, Mix.Project.config()[:version]

config :hammer,
  backend: :ets,
  scale: :timer.minutes(1),
  limit: 100

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
