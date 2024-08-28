defmodule Lexin.Dictionary.Supervisor do
  @moduledoc """
  Maintains Lexin Dictionary's processes tree:

  ```
                    | Dictionary.Supervisor |
                    |-----------------------|
                       /                 |
                      /                  |
                     /                   |

  | Registry                    |   | Repo.Supervisor | - - - > | Repo.Worker |
  |-----------------------------|   |-----------------| - - - > ...
  | stores info about available |   | ...             | - - - > | Repo.Worker |
  | Repo.Worker processes       |
  ```
  """

  use Supervisor

  def start_link(opts),
    do: Supervisor.start_link(__MODULE__, :ok, opts)

  @impl true
  def init(:ok) do
    children = [
      {Registry, name: Lexin.Dictionary.Registry, keys: :unique},
      Lexin.Dictionary.Repo.Supervisor
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
