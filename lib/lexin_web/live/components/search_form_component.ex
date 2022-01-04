defmodule LexinWeb.SearchFormComponent do
  use LexinWeb, :live_component

  @doc """
  Processes form submission by setting current URL to the new one (with updating `query` param),
  the actual data request and handling happens in the corresponding `handle_params/3` function.
  """
  def handle_event(event, params, socket)

  def handle_event("search", %{"query" => query, "lang" => lang}, socket) do
    route =
      Routes.live_path(socket, LexinWeb.DictionaryLive, %{
        query: query,
        lang: lang
      })

    {:noreply, push_patch(socket, to: route)}
  end

  def handle_event("reset", _params, socket) do
    route =
      Routes.live_path(socket, LexinWeb.DictionaryLive, %{
        query: "",
        lang: socket.assigns.lang
      })

    {:noreply, push_patch(socket, to: route)}
  end

  defp localized_languages_select(name, dom_id, selected_lang) do
    translations = [
      {gettext("albanian"), "albanian"},
      {gettext("amharic"), "amharic"},
      {gettext("arabic"), "arabic"},
      {gettext("azerbaijani"), "azerbaijani"},
      {gettext("bosnian"), "bosnian"},
      {gettext("english"), "english"},
      {gettext("finnish"), "finnish"},
      {gettext("greek"), "greek"},
      {gettext("croatian"), "croatian"},
      {gettext("northern_kurdish"), "northern_kurdish"},
      {gettext("pashto"), "pashto"},
      {gettext("persian"), "persian"},
      {gettext("russian"), "russian"},
      {gettext("serbian_latin"), "serbian_latin"},
      {gettext("serbian_cyrillic"), "serbian_cyrillic"},
      {gettext("somali"), "somali"},
      {gettext("spanish"), "spanish"},
      {gettext("swedish"), "swedish"},
      {gettext("southern_kurdish"), "southern_kurdish"},
      {gettext("tigrinya"), "tigrinya"},
      {gettext("turkish"), "turkish"}
    ]

    available = Lexin.Dictionary.Worker.languages()

    supported_languages = Enum.filter(translations, &Enum.member?(available, elem(&1, 1)))

    ui_languages = [{gettext("Select language"), "select_language"} | supported_languages]

    options = options_for_select(ui_languages, selected_lang)

    content_tag(:select, options, name: name, id: dom_id)
  end
end
