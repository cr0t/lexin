defmodule Lexin.Dictionary.Repo.Queries do
  @moduledoc """
  Contains actual SQL-queries which retrieve data from dictionaries; formats output.
  """

  alias Exqlite.Sqlite3, as: SQLite

  @doc """
  Attempts to find definitions in the given SQLite database (connection) and a query to look for.
  """
  @spec find_definitions(db_conn :: any(), query :: String.t()) ::
          {:ok, [Lexin.Definition.t()]} | {:error, atom()}
  def find_definitions(db_conn, query) do
    find_sql = """
    SELECT DISTINCT definition FROM definitions
    JOIN vocabulary ON definitions.id = vocabulary.definition_id
    WHERE vocabulary.word LIKE ?1 OR definitions.word LIKE ?1
    """

    with {:ok, statement} <- SQLite.prepare(db_conn, find_sql),
         _ <- SQLite.bind(statement, [query]),
         {:ok, rows} <- SQLite.fetch_all(db_conn, statement),
         :ok <- SQLite.release(db_conn, statement) do
      format_definitions(rows, query)
    end
  end

  @doc """
  Attempts to find suggestions: takes available Swedish vocabulary and selects words which start
  with the given query. For better performance, limits the selection.
  """
  @spec find_suggestions(db_conn :: any(), query :: String.t()) ::
          {:ok, [String.t()]} | {:error, atom()}
  def find_suggestions(db_conn, query) do
    suggestions_sql = """
    SELECT DISTINCT(word) FROM vocabulary
    WHERE word LIKE ?1
    """

    word_like = "#{query}%"

    with {:ok, statement} <- SQLite.prepare(db_conn, suggestions_sql),
         _ <- SQLite.bind(statement, [word_like]),
         {:ok, rows} <- SQLite.fetch_all(db_conn, statement),
         :ok <- SQLite.release(db_conn, statement) do
      format_suggestions(rows, query)
    end
  end

  # Cleans and orders the list of suggestions
  #
  # Unfortunately, we cannot order by word similarity in the SQLite, so we have to do this on the
  # Elixir side. Though, it's quite straightforward and simple.
  defp format_suggestions([], _),
    do: {:ok, []}

  defp format_suggestions(rows, query) do
    suggestions =
      rows
      |> Enum.map(&hd/1)
      |> Enum.sort_by(&String.bag_distance(&1, query), :desc)

    {:ok, suggestions}
  end

  # Cleans and orders the list of definitions we found
  #
  # Note: we need to extract `definition` from the row list, parse it, and then re-order it by the
  # relevance.
  defp format_definitions([], _),
    do: {:error, :not_found}

  defp format_definitions(rows, query) do
    definitions =
      rows
      |> Enum.map(&hd/1)
      |> Enum.map(&Lexin.Dictionary.Parser.convert/1)
      |> reorder(query)

    {:ok, definitions}
  end

  # We want to pick the most relevant definition(s); it's a bit tricky because sometimes a value
  # in the definition structure can be spelled as compound, for example: for `dammsugare`
  # query value of the most relevant definition is `damm|sugare`.
  defp reorder(definitions, query) do
    most_relevant =
      Enum.filter(definitions, fn %{value: word} ->
        query == String.replace(word, "|", "")
      end)

    less_relevant = Enum.reject(definitions, &Enum.member?(most_relevant, &1))

    # Then we put them first to the new list, and add the rest as a tail (with the top rejected)
    most_relevant ++ less_relevant
  end
end
