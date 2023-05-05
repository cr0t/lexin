defmodule LexinWeb.Layouts do
  @moduledoc false

  use LexinWeb, :html

  embed_templates "layouts/*"

  def app_version(), do: Application.get_env(:lexin, :app_version)
end
