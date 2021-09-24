defmodule Lexin.Service do
  @moduledoc """
  Entrance gateway to the Lexin web service application
  """

  alias Lexin.Service.{Client, Parser}

  @spec lookup(word :: String.t()) :: {:ok, [Lexin.Definition.t()]} | {:error, any()}
  def lookup(word) do
    case Client.definitions(word) do
      {:error, err} ->
        {:error, err}

      {:ok, raw_definitions} ->
        {:ok, Enum.map(raw_definitions, &Parser.convert/1)}
    end
  end
end
