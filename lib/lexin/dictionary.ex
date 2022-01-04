defmodule Lexin.Dictionary do
  @moduledoc """
  Entrance to the Lexin's dictionary data
  """

  alias Lexin.Dictionary.{Worker, Parser}

  @spec lookup(lang :: String.t(), word :: String.t()) ::
          {:ok, [Lexin.Definition.t()]} | {:error, any()}
  def lookup(lang, word) do
    try do
      case Worker.definitions(lang, word) do
        {:ok, raw_definitions} ->
          {:ok, Enum.map(raw_definitions, &Parser.convert/1)}

        {:error, err} ->
          {:error, err}
      end
    rescue
      _err ->
        {:error, :exception_processing_request}
    end
  end
end
