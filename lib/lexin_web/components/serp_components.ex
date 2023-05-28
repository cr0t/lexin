defmodule LexinWeb.SerpComponents do
  @moduledoc """
  Provides partials and view helpers for "Search Results Page".
  """

  use Phoenix.Component

  import LexinWeb.Gettext

  embed_templates "cards/*"

  @doc """
  Represents a definition "card" template, provides a few useful helpers to render the data.
  """
  attr :dfn, :map, required: true
  attr :target_lang, :string, required: true
  def definition(assigns)

  @audio_url_prefix Application.compile_env(:lexin, :external_audio_url_prefix, "")
  @picture_url_prefix Application.compile_env(:lexin, :external_picture_url_prefix, "")
  @picture_languages_map %{
    "albanian" => "swe,sqi",
    "amharic" => "swe,amh",
    "arabic" => "swe,ara",
    "azerbaijani" => "swe",
    "bosnian" => "swe,bos",
    "english" => "swe,eng",
    "finnish" => "swe,fin",
    "greek" => "swe,ell",
    "croatian" => "swe",
    "northern_kurdish" => "swe,kmr",
    "pashto" => "swe",
    "persian" => "swe,fas",
    "russian" => "swe,rus",
    "serbian_latin" => "swe",
    "serbian_cyrillic" => "swe",
    "somali" => "swe,som",
    "spanish" => "swe,spa",
    "swedish" => "swe",
    "southern_kurdish" => "swe,sdh",
    "tigrinya" => "swe,tir",
    "turkish" => "swe,tur"
  }

  defp graminfo(dfn),
    do: dfn.base.graminfo |> String.replace("&", dfn.value)

  defp illustrations(dfn),
    do: dfn.base.illustrations ++ dfn.target.illustrations

  defp inflections(dfn),
    do: [dfn.value | Enum.map(dfn.base.inflections, & &1.value)]

  defp examples(dfn),
    do: Enum.zip(dfn.base.examples, dfn.target.examples)

  defp idioms(dfn),
    do: Enum.zip(dfn.base.idioms, dfn.target.idioms)

  defp compounds(dfn),
    do: Enum.zip(dfn.base.compounds, dfn.target.compounds)

  defp external_audio_url(audio_path),
    do: "#{@audio_url_prefix}#{audio_path}"

  defp external_picture_url(picture_params, target_lang) do
    langs_value = Map.get(@picture_languages_map, target_lang, "swe,swe")
    languages = "languages=#{langs_value}"

    "#{@picture_url_prefix}&#{languages}&#{picture_params}"
  end
end
