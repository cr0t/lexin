defmodule Lexin.Definition do
  @moduledoc false

  @enforce_keys [:id, :pos, :value, :base, :target]
  defstruct [
    :id,
    :pos,
    :value,
    :base,
    :target
  ]

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          pos: String.t(),
          value: String.t(),
          base: Lexin.Definition.Lang.t(),
          target: Lexin.Definition.Lang.t()
        }
end
