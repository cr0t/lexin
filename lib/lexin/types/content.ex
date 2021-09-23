defmodule Lexin.Definition.Content do
  @moduledoc false

  @derive Jason.Encoder

  @enforce_keys [:value]
  defstruct [
    :id,
    :value,
    :inflections
  ]

  @type t :: %__MODULE__{
          id: non_neg_integer() | nil,
          value: String.t(),
          inflections: [Strint.t()]
        }
end
