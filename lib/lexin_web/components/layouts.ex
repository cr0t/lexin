defmodule LexinWeb.Layouts do
  @moduledoc false

  use LexinWeb, :html

  embed_templates "layouts/*"

  def app_version(), do: Application.get_env(:lexin, :app_version)

  @doc """
  Returns a map of IETF Language Tag standard names to the internal languages our app supports.

  We used https://en.wikipedia.org/wiki/IETF_language_tag#List_of_common_primary_language_subtags
  as the information for making this mapping of default language for translations.

  This map is being rendered inline in JavaScript code.

  [!NOTE]
  Somali and Tigrinya languages default to English
  """
  def default_languages_mapping() do
    %{
      "sq" => "albanian",
      "am" => "amharic",
      "ar" => "arabic",
      "az" => "azerbaijani",
      "bs" => "bosnian",
      "en" => "english",
      "fi" => "finnish",
      "el" => "greek",
      "hr" => "croatian",
      "ckb" => "northern_kurdish",
      "ps" => "pashto",
      "fa" => "persian",
      "ru" => "russian",
      "sr" => "serbian_latin",
      "es" => "spanish",
      "sv" => "swedish",
      "tr" => "turkish"
    }
    |> Jason.encode!()
    |> Phoenix.HTML.raw()
  end

end
