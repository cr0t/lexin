defmodule LexinWeb.DictionaryLive.Index do
  @moduledoc """
  Main entrance point for our app. Provides a search form and shows results.

  We want to support GET-params, so users are able to share links to the page they're looking at
  any particular moment. So, we rely on the `?query` parameter a lot.

  In order to handle it properly in LiveView we use `handle_params/3` which runs before `mount/3`.
  """

  use LexinWeb, :live_view

  import LexinWeb.Gettext

  alias LexinWeb.{CardComponent, SearchFormComponent}

  @doc """
  Set up the language in case if user already made searches previously, and her browser stored the
  selected language in its localStorage.

  Check how we populate `socketParams` on the JavaScript side around this initialization code:
  `new LiveSocket('/live', Socket, socketParams)`.
  """
  def mount(_params, _session, socket),
    do: {:ok, assign(socket, lang: get_connect_params(socket)["lang"])}

  @doc """
  When `?query=...&lang=...` presented in the parameters hash, we use it as initial state and
  request data.

  By default (if user opens a page without query parameter) we set everything to clean state.
  """
  def handle_params(params, uri, socket)

  def handle_params(%{"query" => query, "lang" => lang}, _uri, socket) do
    socket =
      assign(socket, %{
        query: String.trim(query),
        in_focus: socket.assigns[:in_focus] || true,
        suggestions: [],
        lang: lang
      })

    {:noreply, find_definitions(socket)}
  end

  def handle_params(_params, _uri, socket) do
    socket =
      assign(socket, %{
        query: "",
        in_focus: socket.assigns[:in_focus] || true,
        suggestions: [],
        definitions: []
      })

    {:noreply, socket}
  end

  ###
  ### Helpers
  ###

  defp find_definitions(%{assigns: %{query: query, lang: lang}} = socket) do
    if String.length(query) > 0 do
      case Lexin.Dictionary.lookup(lang, query) do
        {:ok, definitions} ->
          socket
          |> clear_flash()
          |> assign(:definitions, definitions)
          |> assign(:suggestions, [])

        {:error, err} ->
          socket
          |> put_flash(:error, error_msg(err))
          |> assign(:definitions, [])
      end
    else
      assign(socket, :definitions, [])
    end
  end

  defp error_msg(:not_found),
    do: dgettext("errors", "Not found")

  defp error_msg(:exception_processing_request),
    do: dgettext("errors", "Exception processing search request")

  defp error_msg(:language_not_supported),
    do: dgettext("errors", "Language is not supported")

  defp error_msg(_),
    do: dgettext("errors", "Unknown (yet) error – fun for developers")
end
