defmodule LexinWeb.SearchFormComponent do
  @moduledoc """
  Renders search form (incl. languages dropdown) and handles search requests by maintaining
  GET-params of the URL via `Routes.live_path/3`.

  In its turn, the parent live view component handles these params changes.
  """

  use LexinWeb, :live_component

  @min_chars_for_suggestions 1

  @doc """
  Processes form submission by setting current URL to the new one (with updating `query` param),
  the actual data request and handling happens in the corresponding `handle_params/3` function.
  """
  def handle_event(event, params, socket)

  def handle_event("submit", %{"query" => query, "lang" => lang}, socket) do
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

  def handle_event("update", %{"query" => query, "lang" => lang}, socket) do
    socket =
      assign(socket, %{
        lang: lang,
        query: String.trim(query)
      })

    {:noreply, find_suggestions(socket)}
  end

  def handle_event("query-focus", _params, socket),
    do: {:noreply, assign(socket, query_in_focus: true)}

  def handle_event("query-blur", _params, socket),
    do: {:noreply, assign(socket, query_in_focus: false)}

  ###
  ### Helpers
  ###

  defp localized_languages_select(name, dom_id, selected_lang, opts) do
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

    extra_opts = Keyword.merge(opts, name: name, id: dom_id)

    content_tag(:select, options, extra_opts)
  end

  defp find_suggestions(%{assigns: %{query: query, lang: lang}} = socket) do
    if String.length(query) >= @min_chars_for_suggestions do
      assign(socket, suggestions: Lexin.Dictionary.suggestions(lang, query))
    else
      assign(socket, suggestions: [])
    end
  end

  defp has_suggestions?(_, []), do: false
  defp has_suggestions?(in_focus, _), do: in_focus

  defp suggestion_path(socket, lang, suggestion),
    do: Routes.live_path(socket, LexinWeb.DictionaryLive, %{query: suggestion, lang: lang})
end
