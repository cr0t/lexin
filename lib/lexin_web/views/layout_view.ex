defmodule LexinWeb.LayoutView do
  use LexinWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  @app_version Mix.Project.config()[:version]

  def app_version(), do: @app_version
end
