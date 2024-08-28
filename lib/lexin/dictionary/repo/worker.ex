defmodule Lexin.Dictionary.Repo.Worker do
  @moduledoc """
  References an SQLite connection to the given language database file and handles queries to it.
  """

  use GenServer

  alias Lexin.Dictionary.Repo.Queries

  # Public API

  def definitions(repo, query),
    do: GenServer.call(repo, {:definitions, query})

  def suggestions(repo, query),
    do: GenServer.call(repo, {:suggestions, query})

  # GenServer's Kitchen

  def start_link(opts) do
    language = Keyword.fetch!(opts, :language)
    filepath = Keyword.fetch!(opts, :filepath)

    GenServer.start_link(__MODULE__, filepath, name: via_tuple(language))
  end

  defp via_tuple(language),
    do: {:via, Registry, {Lexin.Dictionary.Registry, language}}

  @impl true
  def init(filepath),
    do: Exqlite.Sqlite3.open(filepath, mode: :readonly)

  @impl true
  def handle_call({:definitions, query}, _from, db_conn),
    do: {:reply, Queries.find_definitions(db_conn, query), db_conn}

  @impl true
  def handle_call({:suggestions, query}, _from, db_conn),
    do: {:reply, Queries.find_suggestions(db_conn, query), db_conn}
end
