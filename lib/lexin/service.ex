defmodule Lexin.Service do
  @moduledoc """
  Entrance gateway to the Lexin web service application
  """

  alias Lexin.Service.{Client, Parser}

  @spec lookup(word :: String.t()) :: [any()]
  def lookup(word) do
    word
    |> Client.definitions()
    |> Enum.map(&Parser.convert/1)
  end
end
