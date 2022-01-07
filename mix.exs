defmodule Lexin.MixProject do
  use Mix.Project

  def project do
    [
      app: :lexin,
      version: "0.5.3",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
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
      {:esbuild, "~> 0.4.0", runtime: Mix.env() == :dev},
      {:exqlite, "~> 0.8.4"},
      {:floki, ">= 0.32.0"},
      {:gettext, "~> 0.19.0"},
      {:hackney, "~> 1.18"},
      {:jason, "~> 1.3.0"},
      {:observer_cli, "~> 1.7.1"},
      {:phoenix, "~> 1.6.5"},
      {:phoenix_html, "~> 3.2.0"},
      {:phoenix_live_dashboard, "~> 0.6.2"},
      {:phoenix_live_reload, "~> 1.3.3", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:plug_cowboy, "~> 2.5.2"},
      {:telemetry_metrics, "~> 0.6.1"},
      {:telemetry_poller, "~> 1.0.0"}
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
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
