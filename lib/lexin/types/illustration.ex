defmodule Lexin.Definition.Illustration do
  @moduledoc false

  @derive Jason.Encoder

  @enforce_keys [:type, :url]
  defstruct [
    :type,
    :url
  ]

  @type t :: %__MODULE__{
          type: String.t(),
          url: String.t()
        }
end
