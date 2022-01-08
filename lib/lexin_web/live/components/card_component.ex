defmodule LexinWeb.CardComponent do
  use LexinWeb, :live_component

  import LexinWeb.Gettext

  @picture_languages %{
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

  def graminfo(dfn),
    do: dfn.base.graminfo |> String.replace("&", dfn.value)

  def illustrations(dfn),
    do: dfn.base.illustrations ++ dfn.target.illustrations

  def inflections(dfn),
    do: [dfn.value | Enum.map(dfn.base.inflections, & &1.value)]

  def examples(dfn),
    do: Enum.zip(dfn.base.examples, dfn.target.examples)

  def idioms(dfn),
    do: Enum.zip(dfn.base.idioms, dfn.target.idioms)

  def compounds(dfn),
    do: Enum.zip(dfn.base.compounds, dfn.target.compounds)

  def external_audio_url(audio_path) do
    prefix = Application.get_env(:lexin, :external_audio_url_prefix)

    "#{prefix}#{audio_path}"
  end

  def external_picture_url(picture_params, target_lang) do
    prefix = Application.get_env(:lexin, :external_picture_url_prefix)
    langs_value = Map.get(@picture_languages, target_lang, "swe,swe")
    languages = "languages=#{langs_value}"

    "#{prefix}&#{languages}&#{picture_params}"
  end
end
