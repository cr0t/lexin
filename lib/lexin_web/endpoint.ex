defmodule LexinWeb.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :lexin

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_lexin_key",
    signing_salt: "dR5hRzKl",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  #
  # We need `only_matching` option to serve listed files after
  # they got digested (with fingerprints in filenames).
  plug Plug.Static,
    at: "/",
    from: :lexin,
    gzip: true,
    only: LexinWeb.static_paths(),
    only_matching: ~w(manifest favicon robots)

  # Sitemaps shall be served at "/" too, but from an external (in relation to the app's root)
  # directory. In production (with Docker env), it must be mounted to the app's container.
  plug Plug.Static,
    at: "/",
    from: {:lexin, LexinWeb.sitemaps_path()},
    gzip: true,
    only_matching: ~w(sitemap)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Sentry.PlugContext

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug LexinWeb.Router
end
