defmodule LexinWeb.ServiceWorkerJS do
  @moduledoc false

  use LexinWeb, :html

  @app_version Mix.Project.config()[:version]

  def app_version(), do: @app_version

  embed_templates "service_worker_js/*"
end
