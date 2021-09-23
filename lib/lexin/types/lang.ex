defmodule Lexin.Definition.Lang do
  @moduledoc false

  @derive Jason.Encoder

  defstruct [
    :meaning,
    :comment,
    :translation,
    :alternate,
    :phonetic,
    :inflections,
    :examples,
    :idioms,
    :compounds,
    :illustrations,
    :antonyms,
    :synonyms
  ]

  @type t :: %__MODULE__{
          meaning: String.t() | nil,
          comment: String.t() | nil,
          translation: String.t() | nil,
          alternate: String.t() | nil,
          phonetic: Lexin.Definition.Phonetic.t() | nil,
          inflections: [Lexin.Definition.Content.t()],
          examples: [Lexin.Definition.Content.t()],
          idioms: [Lexin.Definition.Content.t()],
          compounds: [Lexin.Definition.Content.t()],
          illustrations: [Lexin.Definition.Illustration.t()],
          antonyms: [String.t()],
          synonyms: [String.t()]
        }
end
