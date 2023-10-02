defmodule Lexin.Definition.Phonetic do
  @moduledoc false

  @enforce_keys [:transcription, :audio_url]
  defstruct [
    :transcription,
    :audio_url
  ]

  @type t :: %__MODULE__{
          transcription: String.t(),
          audio_url: String.t() | nil
        }

  # NOTE: audio_url can be nil in some rare cases. For example, one of the definitions of Swedish
  # `stavar` has no `file` attribute in the `phonetic` tag.
  #
  # Check:
  # bash$ sqlite3 english.sqlite
  # sqlite> SELECT * FROM definitions JOIN vocabulary ON definitions.id = vocabulary.definition_id WHERE vocabulary.word LIKE 'stavar';
end
