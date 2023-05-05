defmodule LexinWeb.ServiceWorkerJS do
  @moduledoc false

  use LexinWeb, :html

  def app_version(), do: Application.get_env(:lexin, :app_version)

  embed_templates "service_worker_js/*"
end
