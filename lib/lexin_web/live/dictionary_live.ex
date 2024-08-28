defmodule LexinWeb.DictionaryLive do
  @moduledoc """
  Main entrance point for our app. Provides a search form and shows results.

  We want to support GET-params, so users are able to share links to the page they're looking at
  any particular moment. So, we rely on the `query` parameter a lot.

  In order to handle it properly in LiveView we use `handle_params/3` which runs before `mount/3`.
  """

  use LexinWeb, :live_view

  import LexinWeb.SEO

  alias LexinWeb.{SearchFormComponent, SerpComponents}

  @doc """
  Set up the language in case if user already made searches previously, and her browser stored the
  selected language in its localStorage.

  Check how we populate `socketParams` on the JavaScript side around this initialization code:
  `new LiveSocket('/live', Socket, socketParams)`.
  """
  def mount(_params, _session, socket) do
    lang = get_connect_params(socket)["lang"]

    # See comment below, next to this function definition
    # maybe_set_locale(lang)

    {:ok, assign(socket, lang: lang)}
  end

  @doc """
  When `query` and `lang` are presented in the parameters hash, we use them as initial state and
  request data.

  By default (if user opens a home page) we set everything to clean state.
  """
  def handle_params(%{"query" => query, "lang" => lang}, _uri, socket) do
    # See comment below, next to this function definition
    # maybe_set_locale(lang)

    socket =
      socket
      |> preset_params(String.trim(query), lang)
      |> find_definitions()

    {:noreply, socket}
  end

  def handle_params(params, _uri, socket),
    do: {:noreply, preset_params(socket, "", params["lang"])}

  ###
  ### Helpers
  ###

  defp preset_params(socket, query, lang) do
    assign(socket, %{
      query: query,
      lang: lang || socket.assigns[:lang],
      in_focus: socket.assigns[:in_focus] || true,
      suggestions: [],
      definitions: []
    })
  end

  defp find_definitions(%{assigns: %{lang: lang, query: query}} = socket) do
    if String.length(query) > 0 do
      case Lexin.Dictionary.definitions(lang, query) do
        {:ok, definitions} ->
          socket
          |> clear_flash()
          |> assign(:definitions, definitions)
          |> assign(:suggestions, [])
          |> assign(:page_title, page_title(query, definitions))
          |> assign(:meta_desc, meta_desc(query, definitions))

        {:error, err} ->
          socket
          |> put_flash(:error, error_msg(err))
          |> assign(:definitions, [])
      end
    else
      assign(socket, :definitions, [])
    end
  end

  # TODO: Find a way how to set locale without "jumps" in UI. At the moment, due to the way how we
  # set previously chosen language (via localStorage), for a moment users see the default locale
  # (Swedish) labels and messages, and then switch to the chosen one. It's annoying...
  #
  # defp maybe_set_locale("english"), do: Gettext.put_locale(LexinWeb.Gettext, "en")
  # defp maybe_set_locale("russian"), do: Gettext.put_locale(LexinWeb.Gettext, "ru")
  # defp maybe_set_locale(_), do: Gettext.put_locale(LexinWeb.Gettext, "sv")

  defp error_msg(:not_found),
    do: dgettext("errors", "Not found")

  defp error_msg(:exception_processing_request),
    do: dgettext("errors", "Exception processing search request")

  defp error_msg(:language_not_supported),
    do: dgettext("errors", "Language is not supported")

  defp error_msg(_),
    do: dgettext("errors", "Unknown (yet) error – fun for developers")
end
