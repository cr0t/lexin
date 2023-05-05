defmodule LexinWeb.Layouts do
  @moduledoc false

  use LexinWeb, :html

  embed_templates "layouts/*"

  @app_version Mix.Project.config()[:version]

  def app_version(), do: @app_version
end
