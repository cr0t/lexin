defmodule Lexin.Dictionary.Worker do
  @moduledoc """
  Local filesystem dictionary service, uses SQLite dictionaries from the pre-configured directory.
  """

  alias Lexin.Dictionary.Data

  # restart only if terminates abnormally
  use GenServer, restart: :transient

  # Public API

  def languages(),
    do: GenServer.call(__MODULE__, :languages)

  def definitions(lang, word),
    do: GenServer.call(__MODULE__, {:definitions, lang, word})

  # Initialization

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts),
    do: {:ok, Data.load_dictionaries()}

  # GenServer's Kitchen

  @impl true
  def handle_call(:languages, _from, dicts),
    do: {:reply, Map.keys(dicts), dicts}

  @impl true
  def handle_call({:definitions, lang, query}, _from, dicts) do
    if valid_language?(dicts, lang) do
      {:reply, Data.find_definitions(dicts[lang], query), dicts}
    else
      {:reply, {:error, :language_not_supported}, dicts}
    end
  end

  # Other little Santa's helpers

  defp valid_language?(dictionaries, lang),
    do: Map.has_key?(dictionaries, lang)
end
