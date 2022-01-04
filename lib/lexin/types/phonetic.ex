defmodule Lexin.Definition.Phonetic do
  @moduledoc false

  @enforce_keys [:transcription, :audio_url]
  defstruct [
    :transcription,
    :audio_url
  ]

  @type t :: %__MODULE__{
          transcription: String.t(),
          audio_url: String.t()
        }
end
