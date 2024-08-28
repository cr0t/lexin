defmodule Lexin.Dictionary.Repo do
  @moduledoc """
  Provides access to the actual dictionary workers and request required data from them.
  """

  alias Lexin.Dictionary.Repo.Worker

  @max_suggestions 8

  def definitions(language, query) do
    with {:ok, repo} <- repo_for(language),
         normalized_query <- normalize(query) do
      Worker.definitions(repo, normalized_query)
    end
  end

  def suggestions(language, query) do
    with {:ok, repo} <- repo_for(language),
         normalized_query <- normalize(query),
         {:ok, suggestions} <- Worker.suggestions(repo, normalized_query) do
      Enum.take(suggestions, @max_suggestions)
    end
  end

  defp repo_for(language) do
    case Registry.lookup(Lexin.Dictionary.Registry, language) do
      [{repo, _}] -> {:ok, repo}
      _ -> {:error, :language_not_supported}
    end
  end

  defp normalize(query),
    do: query |> String.downcase() |> String.trim()
end
