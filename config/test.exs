import Config

# NOTE: because of the way how we build the full path for dictionaries, we have to set it to a
# relative here to point it to the repo's root instead of something inside the _build/test/...
config :lexin, :dictionaries_path, "../../../../test/fixtures/dictionaries"
config :lexin, :sitemaps_path, "../../../../test/fixtures/sitemaps"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lexin, LexinWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8Q7QHw+qU9xnuRwI3P2MSGyDS6auQl/8Ki7GCB63toa6fS9kusXiFW9qExob1T/+",
  server: true

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# A few settings for Wallaby
config :wallaby,
  driver: Wallaby.Chrome,
  base_url: "http://localhost:4002",
  screenshot_on_failure: true
