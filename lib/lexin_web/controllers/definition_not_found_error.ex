defmodule LexinWeb.DefinitionNotFoundError do
  defexception [:message, plug_status: 404]
end
