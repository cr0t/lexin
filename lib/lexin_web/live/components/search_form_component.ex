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
    # See docs Lexin.Service.Client regarding Swedish language support
    supported_languages = [
      {gettext("Select language"), :select_language},
      {gettext("albanian"), :albanian},
      {gettext("arabic"), :arabic},
      {gettext("bosnian"), :bosnian},
      {gettext("finnish"), :finnish},
      {gettext("greek"), :greek},
      {gettext("croatian"), :croatian},
      {gettext("northern_kurdish"), :northern_kurdish},
      {gettext("persian"), :persian},
      {gettext("russian"), :russian},
      {gettext("serbian"), :serbian},
      {gettext("somali"), :somali},
      {gettext("southern_kurdish"), :southern_kurdish},
      # {gettext("swedish"), :swedish},
      {gettext("turkish"), :turkish}
    ]

    options = options_for_select(supported_languages, selected_lang)

    content_tag(:select, options, [name: name, id: dom_id])
  end
end
