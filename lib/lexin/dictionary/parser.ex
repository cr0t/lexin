defmodule Lexin.Dictionary.Parser do
  @moduledoc """
  Converts raw definition XML to our internal data structure representation.
  """

  @spec convert(raw_xml :: String.t()) :: Lexin.Definition.t()
  def convert(raw_xml) do
    {:ok, html} = Floki.parse_fragment(raw_xml)

    %Lexin.Definition{
      id: attribute(html, "variantid") |> parse_integer(),
      pos: attribute(html, "type"),
      value: attribute(html, "value"),
      base: child(html, "baselang") |> parse_lang(),
      target: child(html, "targetlang") |> parse_lang()
    }
  end

  # TODO: Check and fix parsing according to LexinSchema.xsd. For example, we need to follow
  # number of occurences for different sub-pieces of definition (only one synonym, for example).
  defp parse_lang(html) do
    %Lexin.Definition.Lang{
      meaning: child_text(html, "meaning"),
      usage: child_text(html, "usage"),
      graminfo: child_text(html, "graminfo"),
      comment: child_text(html, "comment"),
      translation: child_text(html, "translation"),
      alternate: child_text(html, "alternate"),
      phonetic: child(html, "phonetic") |> parse_phonetic(),
      inflections: children(html, "inflection") |> parse_contents(),
      examples: children(html, "example") |> parse_contents(),
      idioms: children(html, "idiom") |> parse_contents(),
      compounds: children(html, "compound") |> parse_contents(),
      illustrations: children(html, "illustration") |> parse_illustrations(),
      antonyms: children(html, "antonym") |> Floki.attribute("value"),
      synonyms: children(html, "synonym") |> parse_strings()
    }
  end

  defp parse_phonetic(nil), do: nil

  defp parse_phonetic(html) do
    %Lexin.Definition.Phonetic{
      transcription: Floki.text(html),
      audio_url: attribute(html, "file")
    }
  end

  defp parse_contents(htmls) do
    htmls
    |> Enum.map(fn html ->
      %Lexin.Definition.Content{
        id: attribute(html, "id") |> parse_integer(),
        inflections: children(html, "inflection") |> parse_strings(),
        value: Floki.text(html)
      }
    end)
  end

  defp parse_illustrations(htmls) do
    htmls
    |> Enum.map(fn html ->
      %Lexin.Definition.Illustration{
        type: attribute(html, "type"),
        url: attribute(html, "norlexin")
      }
    end)
  end

  defp child(html, selector), do: Floki.find(html, selector) |> List.first()

  defp children(html, selector), do: Floki.find(html, selector)

  defp attribute(html, attr), do: Floki.attribute(html, attr) |> List.first()

  defp child_text(html, selector) do
    text = Floki.find(html, selector) |> Floki.text()

    if String.length(text) > 0, do: text, else: nil
  end

  defp parse_integer(nil), do: nil
  defp parse_integer(""), do: nil
  defp parse_integer(n), do: String.to_integer(n)

  defp parse_strings([""]), do: []
  defp parse_strings(list), do: Enum.map(list, &Floki.text/1)
end
