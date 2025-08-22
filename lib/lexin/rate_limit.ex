defmodule Lexin.RateLimit do
  @moduledoc false
  use Hammer, backend: Application.compile_env(:hammer, :backend)
end
