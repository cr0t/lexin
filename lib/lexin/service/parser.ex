defmodule Lexin.Service.Parser do
  @moduledoc """
  Converts raw JSON of definition into out internal data structure representation
  """

  @spec convert(raw :: map()) :: Lexin.Definition.t()
  def convert(raw) do
    %Lexin.Definition{
      id: parse_integer(raw["VariantID"]),
      pos: raw["Type"],
      value: raw["Value"],
      base: parse_lang(raw["BaseLang"]),
      target: parse_lang(raw["TargetLang"])
    }
  end

  defp parse_lang(raw) do
    %Lexin.Definition.Lang{
      meaning: raw["Meaning"],
      comment: raw["Comment"],
      translation: raw["Translation"],
      alternate: raw["Alternate"],
      phonetic: parse_phonetic(raw["Phonetic"]),
      inflections: parse_contents(raw["Inflection"]),
      examples: parse_contents(raw["Example"]),
      idioms: parse_contents(raw["Idiom"]),
      compounds: parse_contents(raw["Compound"]),
      illustrations: parse_illustrations(raw["Illustration"]),
      antonyms: parse_strings(raw["Antonym"]),
      synonyms: parse_strings(raw["Synonym"])
    }
  end

  defp parse_phonetic(nil), do: nil

  defp parse_phonetic(raw) do
    %Lexin.Definition.Phonetic{
      transcription: raw["Content"],
      audio_url: raw["File"]
    }
  end

  defp parse_contents(nil), do: []

  defp parse_contents(raws) do
    raws
    |> Enum.map(fn raw ->
      %Lexin.Definition.Content{
        id: parse_integer(raw["ID"]),
        inflections: parse_strings(raw["Inflection"]),
        value: raw["Content"]
      }
    end)
  end

  defp parse_illustrations(nil), do: []

  defp parse_illustrations(raws) do
    raws
    |> Enum.map(fn raw ->
      %Lexin.Definition.Illustration{
        type: raw["Type"],
        url: raw["Value"]
      }
    end)
  end

  defp parse_integer(nil), do: nil
  defp parse_integer(""), do: nil
  defp parse_integer(n), do: String.to_integer(n)

  defp parse_strings(nil), do: []
  defp parse_strings([""]), do: []
  defp parse_strings(list), do: list
end
