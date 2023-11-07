defmodule LexinWeb.SEO do
  @moduledoc """
  Provides Search Engine Optimization (SEO) generators and helpers.

  Meta text generation schema:

  word - translation · 2-3 compounds+examples · Lexin Mobi

  Page title examples:

  bil - car, motorcar, (automobile [US]), (auto [US]) · bil|trafik bil|trafiken - motor traffic · personbil - passenger car · bil|buren - motorized · Lexin Mobi
  lastbil - lorry, (truck [US]) · Lexin Mobi
  vatten - water · dricksvatten - drinking water · badvatten - bathwater · havsvatten - seawater · Lexin Mobi
  som - as · arbeta som guide - work as a guide · om jag vore som du - if I were you · han är lika gammal som sin fru - he is the same age as his wife · Lexin Mobi

  For meta description tags we use the similar approach, but use more definitions (when available),
  and skip the " · Lexin Mobi" suffix in the end.
  """

  @joiner " · "

  def default_title, do: "Lexin Mobi"

  def default_desc do
    "Lexin Mobi is a combination of Swedish vocabulary (lexicon) and dictionary that have been developed for use in primarily immigrant education. The encyclopedia is available both as an online search service and as a mobile application."
  end

  def page_title(""), do: default_title()

  def page_title(word, definitions),
    do: Enum.join([generate_meta(word, definitions, 1), default_title()], @joiner)

  def meta_desc("", _), do: default_desc()
  def meta_desc(word, definitions), do: generate_meta(word, definitions, 3)

  defp generate_meta(word, definitions, limit) do
    definitions
    |> Enum.take(limit)
    |> Enum.map(&definition_info/1)
    |> Enum.map_join(@joiner, &info_to_text(word, &1))
  end

  defp info_to_text(word, info) do
    translation = info.translation
    examples = Enum.take(info.compounds ++ info.examples, 3) |> Enum.join(@joiner)

    if String.length(examples) > 0 do
      "#{word} - #{translation}#{@joiner}#{examples}"
    else
      "#{word} - #{translation}"
    end
  end

  defp definition_info(dfn) do
    examples =
      dfn.base.examples
      |> Enum.zip(dfn.target.examples)
      |> Enum.map(&pair/1)

    compounds =
      dfn.base.compounds
      |> Enum.zip(dfn.target.compounds)
      |> Enum.map(&pair/1)

    %{
      translation: dfn.target.translation,
      compounds: compounds,
      examples: examples
    }
  end

  defp pair({base, target}), do: "#{base.value} - #{target.value}"
end
