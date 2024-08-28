defmodule Lexin.Dictionary.Repo.Supervisor do
  @moduledoc """
  Initializes worker process that are going to handle connections to the SQLite files.
  """

  use Supervisor

  def start_link(opts),
    do: Supervisor.start_link(__MODULE__, :ok, opts)

  @impl true
  def init(:ok) do
    repos =
      for {lang, file} <- Application.get_env(:lexin, :dictionaries) do
        opts = [language: lang, filepath: file]

        Supervisor.child_spec({Lexin.Dictionary.Repo.Worker, opts}, id: lang)
      end

    Supervisor.init(repos, strategy: :one_for_one)
  end
end
