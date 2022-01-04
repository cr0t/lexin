defmodule Lexin.Dictionary.Data do
  @moduledoc """
  Provides low-level access to work with SQLite dictionaries' files
  """

  alias Exqlite.Sqlite3, as: SQLite

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
  @spec find_definitions(db :: any(), query :: String.t()) :: {:ok, [String.t()]} | {:error, atom()}
  def find_definitions(db, query) do
    find_sql = """
    SELECT DISTINCT definition FROM definitions
    JOIN vocabulary ON definitions.id = vocabulary.definition_id
    WHERE vocabulary.word LIKE ?1 OR definitions.word LIKE ?1
    """

    with {:ok, statement} <- SQLite.prepare(db, find_sql),
         :ok <- SQLite.bind(db, statement, [query]),
         {:ok, rows} = SQLite.fetch_all(db, statement) do
      # release the statement to free memory
      :ok = SQLite.release(db, statement)

      if length(rows) > 0 do
        # we need to extract `definition` from the row list
        {:ok, Enum.map(rows, &hd/1)}
      else
        {:error, :not_found}
      end
    else
      err -> err
    end
  end
end
