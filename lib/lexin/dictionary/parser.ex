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
      reference: child(html, "reference") |> parse_references(),
      phonetic: child(html, "phonetic") |> parse_phonetic(),
      inflections: children(html, "inflection") |> parse_contents(),
      examples: children(html, "example") |> parse_contents(),
      idioms: children(html, "idiom") |> parse_contents(),
      compounds: children(html, "compound") |> parse_contents(),
      derivations: children(html, "derivation") |> parse_contents(),
      illustrations: children(html, "illustration") |> parse_illustrations(),
      antonyms: children(html, "antonym") |> Floki.attribute("value"),
      synonyms: children(html, "synonym") |> parse_strings()
    }
  end

  defp parse_references(nil), do: nil

  defp parse_references(html) do
    value = attribute(html, "value")

    case attribute(html, "type") do
      "animation" ->
        %Lexin.Definition.Reference{
          type: :animation,
          values: [String.replace(value, ~r/\.swf$/, ".mp4")]
        }

      "phonetic" ->
        %Lexin.Definition.Reference{
          type: :phonetic,
          values: [String.replace(value, ~r/\.swf$/, ".mp3") |> latin1_rename()]
        }

      "compare" ->
        %Lexin.Definition.Reference{
          type: :compare,
          # remove &quot; and similar from the value
          values: [String.replace(value, ~r/&(?:[a-z\d]+);/, "")]
        }

      "see" ->
        %Lexin.Definition.Reference{
          type: :see,
          values: String.split(value, ",", trim: true) |> Enum.map(&String.trim/1)
        }
    end
  end

  defp parse_phonetic(nil), do: nil

  defp parse_phonetic(html) do
    %Lexin.Definition.Phonetic{
      transcription: Floki.text(html),
      audio_url: attribute(html, "file") |> latin1_rename()
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

  # Does a quite unusual conversion to the given string by replacing non-ASCII characters with
  # their octal equivalents from Latin 1 (ISO-8859-1) encoding page.
  #
  # Examples:
  # - urspårning => ursp0345rning
  # - pärlemor => p0344rlemor
  # - omvänt baksträck -> omv0344nt bakstr0344ck
  # - död(s) => d0366d(s)
  # - dossié => dossi0351
  #
  # See more:
  # - https://www.erlang.org/doc/man/unicode.html#characters_to_nfc_list-1
  # - https://www.ic.unicamp.br/~stolfi/EXPORT/www/ISO-8859-1-Encoding.html
  defp latin1_rename(nil), do: nil

  defp latin1_rename(filename) when is_binary(filename) do
    filename
    |> :unicode.characters_to_nfc_list()
    |> Enum.map(fn
      c when c >= 192 -> "0#{Integer.to_string(c, 8)}"
      c -> to_string([c])
    end)
    |> to_string()
  end
end
