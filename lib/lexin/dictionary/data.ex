defmodule Lexin.Dictionary.Data do
  @moduledoc """
  Provides low-level access to work with SQLite dictionaries' files
  """

  alias Exqlite.Sqlite3, as: SQLite
  alias Lexin.Dictionary.Parser

  @max_suggestions 8

  @doc """
  Returns pre-configured main directory with SQLite files
  """
  @spec dictionaries_root() :: String.t()
  def dictionaries_root(), do: Application.get_env(:lexin, :dictionaries_root)

  @doc """
  Looks into dictionaries root directory for *.sqlite files that contain data for languages.
  Opens a new Exqlite connection to each file and returns a map of filename => connection.
  """
  @spec load_dictionaries() :: Map.t()
  def load_dictionaries() do
    extension = ".sqlite"

    [dictionaries_root(), "*#{extension}"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.map(fn filename ->
      lang =
        filename
        |> Path.basename()
        |> String.replace(extension, "")

      {:ok, db} = SQLite.open(filename)

      {lang, db}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Attempts to find definitions in the given SQLite database (connection) and a query to look for.
  """
  @spec find_definitions(db :: any(), query :: String.t()) ::
          {:ok, [Lexin.Definition.t()]} | {:error, atom()}
  def find_definitions(db, query) do
    find_sql = """
    SELECT DISTINCT definition FROM definitions
    JOIN vocabulary ON definitions.id = vocabulary.definition_id
    WHERE vocabulary.word LIKE ?1 OR definitions.word LIKE ?1
    """

    with {:ok, statement} <- SQLite.prepare(db, find_sql),
         :ok <- SQLite.bind(db, statement, [query]),
         {:ok, rows} <- SQLite.fetch_all(db, statement),
         :ok <- SQLite.release(db, statement) do
      format_definitions(rows, query)
    end
  end

  @doc """
  Attempts to find suggestions: takes available Swedish vocabulary and selects words which start
  with the given query. For better performance, limits the selection.
  """
  @spec find_suggestions(db :: any(), query :: String.t()) ::
          {:ok, [String.t()]} | {:error, atom()}
  def find_suggestions(db, query) do
    suggestions_sql = """
    SELECT DISTINCT(word) FROM vocabulary
    WHERE word LIKE ?1
    """

    word_like = "#{query}%"

    with {:ok, statement} <- SQLite.prepare(db, suggestions_sql),
         :ok <- SQLite.bind(db, statement, [word_like]),
         {:ok, rows} <- SQLite.fetch_all(db, statement),
         :ok <- SQLite.release(db, statement) do
      format_suggestions(rows, query)
    end
  end

  # Cleans and orders the list of suggestions
  #
  # Unfortunately, we cannot order by word similarity in the SQLite, so we have to do this on the
  # Elixir side. Though, it's quite straightforward and simple.

  defp format_suggestions([], _), do: {:ok, []}

  defp format_suggestions(rows, query) do
    suggestions =
      rows
      |> Enum.map(&hd/1)
      |> Enum.sort_by(&String.bag_distance(&1, query), :desc)
      |> Enum.take(@max_suggestions)

    {:ok, suggestions}
  end

  # Cleans and orders the list of definitions we found
  #
  # Note: we need to extract `definition` from the row list, parse it, and then re-order it by the
  # relevance.

  defp format_definitions([], _), do: {:error, :not_found}

  defp format_definitions(rows, query) do
    definitions =
      rows
      |> Enum.map(&hd/1)
      |> Enum.map(&Parser.convert/1)
      |> reorder(query)

    {:ok, definitions}
  end

  # We want to pick the most relevant definition(s); it's a little bit tricky, because sometimes
  # the value in the definition structure can be spelled as compound, for example:
  # for `dammsugare` query value of the most relevant definition is `damm|sugare`
  defp reorder(definitions, query) do
    top_relevant =
      Enum.filter(definitions, fn %{value: word} ->
        query == String.replace(word, "|", "")
      end)

    less_relevant = Enum.reject(definitions, &Enum.member?(top_relevant, &1))

    # Then we put them first to the new list, and add the rest as a tail (with the top rejected)
    top_relevant ++ less_relevant
  end
end
