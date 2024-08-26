defmodule Lexin.MixProject do
  use Mix.Project

  def project do
    [
      app: :lexin,
      version: "0.15.3",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Lexin.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 1.7.4", only: [:dev, :test], runtime: false},
      {:dns_cluster, "~> 0.1.1"},
      {:esbuild, "~> 0.8.1", runtime: Mix.env() == :dev},
      {:exqlite, "~> 0.23.0"},
      {:floki, "~> 0.36.2"},
      {:gettext, "~> 0.26.1"},
      {:hackney, "~> 1.20.1"},
      {:jason, "~> 1.4.1"},
      {:observer_cli, "~> 1.7.4"},
      {:phoenix, "~> 1.7.10"},
      {:phoenix_html, "~> 4.1.1"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:phoenix_live_reload, "~> 1.5.3", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},
      {:plug_cowboy, "~> 2.7.1"},
      {:recon, "~> 2.5.4"},
      {:sentry, "~> 10.7.0"},
      {:tailwind, "~> 0.2.2", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0.0"},
      {:telemetry_poller, "~> 1.1.0"},
      {:wallaby, "~> 0.30.6", only: :test, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      "gettext.update": ["gettext.extract --merge --no-fuzzy"],
      test: ["esbuild default", "test"],
      "sitemap.gen": ["run --no-start scripts/sitemap_generator.exs"],
      "sitemap.check": ["run --no-start scripts/sitemap_tester.exs"]
    ]
  end
end
