defmodule Lexin.Dictionary do
  @moduledoc """
  Entrance to the Lexin's dictionary data
  """

  alias Lexin.Dictionary.Worker

  @spec lookup(lang :: String.t(), word :: String.t()) ::
          {:ok, [Lexin.Definition.t()]} | {:error, any()}
  def lookup(lang, word) do
    try do
      Worker.definitions(lang, word)
    rescue
      error ->
        information = %{lang: lang, word: word}
        Sentry.capture_exception(error, stacktrace: __STACKTRACE__, extra: %{extra: information})

        {:error, :exception_processing_request}
    end
  end
end
