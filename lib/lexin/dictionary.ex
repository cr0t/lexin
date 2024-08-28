defmodule Lexin.Dictionary do
  @moduledoc """
  Entrance to the Lexin's dictionary data.

  Responsible for getting definitions, suggestions, and other relevant dictionary data.
  """

  defdelegate definitions(language, query), to: Lexin.Dictionary.Repo
  defdelegate suggestions(language, query), to: Lexin.Dictionary.Repo

  def languages(),
    do: Application.get_env(:lexin, :dictionaries) |> Map.keys() |> Enum.sort()
end
