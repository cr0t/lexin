defmodule Lexin.Dictionary do
  @moduledoc """
  Entrance to the Lexin's dictionary data
  """

  alias Lexin.Dictionary.Worker

  @spec lookup(lang :: String.t(), query :: String.t()) ::
          {:ok, [Lexin.Definition.t()]} | {:error, any()}
  def lookup(lang, query) do
    try do
      normalized_query = String.downcase(query)

      Worker.definitions(lang, normalized_query)
    rescue
      error ->
        information = %{lang: lang, query: query}
        Sentry.capture_exception(error, stacktrace: __STACKTRACE__, extra: %{extra: information})

        {:error, :exception_processing_request}
    end
  end
end
