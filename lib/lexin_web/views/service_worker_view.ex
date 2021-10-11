defmodule LexinWeb.ServiceWorkerView do
  use LexinWeb, :view

  @app_version Mix.Project.config()[:version]

  def app_version(), do: @app_version
end
