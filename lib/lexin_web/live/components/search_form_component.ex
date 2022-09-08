defmodule LexinWeb.SearchFormComponent do
  @moduledoc """
  Renders search form (incl. languages dropdown) and handles search requests by maintaining
  GET-params of the URL via `Routes.live_path/3`.

  In its turn, the parent live view component handles these params changes.
  """

  use LexinWeb, :live_component

  @min_chars_for_suggestions 1
  @select_lang_prompt "select_language"

  @doc """
  Processes form submission by setting current URL to the new one (with updating `query` param),
  the actual data request and handling happens in the corresponding `handle_params/3` function.
  """
  def handle_event(event, params, socket)

  def handle_event("submit", %{"query" => query, "lang" => lang}, socket),
    do: do_search(socket, query, lang)

  def handle_event("reset", _params, socket),
    do: do_search(socket, "", socket.assigns.lang)

  def handle_event("switch-language", %{"lang" => lang}, socket),
    do: do_search(socket, socket.assigns.query, lang)

  def handle_event("query-focus", _params, socket),
    do: {:noreply, assign(socket, in_focus: true)}

  def handle_event("suggest", %{"query" => query}, socket) do
    query = String.trim(query)
    suggestions = find_suggestions(socket.assigns.lang, query)

    socket =
      assign(socket, %{
        query: query,
        suggestions: suggestions,
        in_focus: true
      })

    {:noreply, socket}
  end

  ###
  ### Helpers
  ###

  defp do_search(socket, query, lang) do
    route =
      Routes.live_path(socket, LexinWeb.DictionaryLive, %{
        query: query,
        lang: lang
      })

    {:noreply, push_patch(socket, to: route)}
  end

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

    ui_languages = [{gettext("Select language"), @select_lang_prompt} | supported_languages]

    options = options_for_select(ui_languages, selected_lang)

    extra_opts = Keyword.merge(opts, name: name, id: dom_id)

    content_tag(:select, options, extra_opts)
  end

  # We want to avoid unnecessary calls of `Lexin.Dictionary.suggestions/2`
  # when user didn't select language yet.
  defp find_suggestions(@select_lang_prompt, _query),
    do: []

  defp find_suggestions(lang, query) do
    if String.length(query) >= @min_chars_for_suggestions do
      Lexin.Dictionary.suggestions(lang, query)
    else
      []
    end
  end

  defp has_suggestions?(_, []), do: false
  defp has_suggestions?(in_focus, _), do: in_focus

  defp suggestion_path(socket, lang, suggestion),
    do: Routes.live_path(socket, LexinWeb.DictionaryLive, %{query: suggestion, lang: lang})
end
