defmodule Lexin.Dictionary do
  @moduledoc """
  Entrance to the Lexin's dictionary data
  """

  alias Lexin.Dictionary.Worker

  @doc """
  Search for definitions for the given query in the given language. Uses our Dictionary.Worker
  process to retrieve the data.
  """
  @spec lookup(lang :: String.t(), query :: String.t()) ::
          {:ok, [Lexin.Definition.t()]} | {:error, any()}
  def lookup(lang, query) do
    try do
      Worker.definitions(lang, normalize(query))
    rescue
      error ->
        information = %{lang: lang, query: query}
        Sentry.capture_exception(error, stacktrace: __STACKTRACE__, extra: %{extra: information})

        {:error, :exception_processing_request}
    end
  end

  @doc """
  Look up for suggestions for the given query in Swedish vocabulary. `lang` doesn't play a
  significant role (yet) – we need it to pick a correct dictionary database file in the
  underlying code.
  """
  @spec suggestions(lang :: String.t(), query :: String.t()) :: [String.t()]
  def suggestions(lang, query) do
    try do
      case Worker.suggestions(lang, normalize(query)) do
        {:ok, list} -> list
        _ -> []
      end
    rescue
      error ->
        information = %{lang: lang, query: query}
        Sentry.capture_exception(error, stacktrace: __STACKTRACE__, extra: %{extra: information})

        # Notify Sentry, but return an empty list of suggestions to the end user – it should not
        # affect main feature of the application.
        []
    end
  end

  defp normalize(query), do: String.downcase(query)
end
