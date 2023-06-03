defmodule Lexin.MixProject do
  use Mix.Project

  def project do
    [
      app: :lexin,
      version: "0.11.1",
      elixir: "~> 1.14",
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
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:esbuild, "~> 0.7.0", runtime: Mix.env() == :dev},
      {:exqlite, "~> 0.13.10"},
      {:floki, "~> 0.34.2"},
      {:gettext, "~> 0.22.1"},
      {:hackney, "~> 1.18.1"},
      {:jason, "~> 1.4.0"},
      {:observer_cli, "~> 1.7.3"},
      {:phoenix, "~> 1.7.2"},
      {:phoenix_html, "~> 3.3.1"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:phoenix_live_reload, "~> 1.4.1", only: :dev},
      {:phoenix_live_view, "~> 0.18.18"},
      {:plug_cowboy, "~> 2.6.1"},
      {:recon, "~> 2.5.3"},
      {:sentry, "~> 8.0.6"},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6.1"},
      {:telemetry_poller, "~> 1.0.0"},
      {:wallaby, "~> 0.30.3", only: :test, runtime: false}
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
      test: ["esbuild default", "test"]
    ]
  end
end
