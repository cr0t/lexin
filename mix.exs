defmodule Lexin.MixProject do
  use Mix.Project

  @app :lexin
  @version "0.17.10"

  def project do
    [
      app: @app,
      version: @version,
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
      {:esbuild, "~> 0.9.0", runtime: Mix.env() == :dev},
      {:exqlite, "~> 0.29.0"},
      {:floki, "~> 0.37.0"},
      {:gettext, "~> 0.26.1"},
      {:hackney, "~> 1.23.0"},
      {:image, "~> 0.59.0"},
      {:jason, "~> 1.4.1"},
      {:observer_cli, "~> 1.8.0"},
      {:phoenix, "~> 1.7.10"},
      {:phoenix_html, "~> 4.2.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:phoenix_live_reload, "~> 1.5.3", only: :dev},
      {:phoenix_live_view, "~> 1.0.1"},
      {:phoenix_seo, "~> 0.1.10"},
      {:plug_cowboy, "~> 2.7.1"},
      {:recon, "~> 2.5.4"},
      {:sentry, "~> 10.8.0"},
      {:tailwind, "~> 0.3.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.1.0"},
      {:telemetry_poller, "~> 1.2.0"},
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
      "sitemap.check": ["run --no-start scripts/sitemap_tester.exs"],
      build: ["build.check", &build_confirmed?/1, "build.run"],
      "build.check": [
        "cmd git status --porcelain | grep . && echo \"'error: Working directory is dirty'\" && exit 1 || exit 0",
        "cmd mix test --warnings-as-errors"
      ],
      "build.run": "cmd ./scripts/build.sh ghcr.io/cr0t/#{@app}:#{@version}"
    ]
  end

  defp build_confirmed?(_) do
    with true <- Mix.shell().yes?("Have you generated sitemaps and put them to the server?"),
         true <- Mix.shell().yes?("Have you ran `gzip -k *` in the sitemaps directory?"),
         true <- Mix.shell().yes?("Have you bumped Lexin's version?") do
      :ok
    else
      _ ->
        IO.puts("error: Cancelling build...")

        System.halt(1)
        Process.sleep(:infinity)
    end
  end
end
