defmodule Lexin.Definition.Reference do
  @moduledoc false

  @enforce_keys [:type, :values]
  defstruct [:type, :values]

  @type t :: %__MODULE__{
          type: :animation | :compare | :phonetic | :see,
          values: [String.t()]
        }
end
