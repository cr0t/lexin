defmodule LexinWeb.DictionaryLive do
  use LexinWeb, :live_view

  import LexinWeb.Gettext

  alias LexinWeb.CardComponent

  def mount(_params, _session, socket) do
    socket =
      assign(socket, %{
        query: "",
        definitions: []
      })

    {:ok, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    socket =
      case search(query) do
        {:ok, definitions} ->
          socket
          |> clear_flash()
          |> assign(:definitions, definitions)

        {:error, err} ->
          socket
          |> put_flash(:error, error_msg(err))
          |> assign(:definitions, [])
      end

    socket = assign(socket, :query, query)

    {:noreply, socket}
  end

  defp search(query), do: Lexin.Service.lookup(query)

  defp error_msg(:not_found),
    do: dgettext("errors", "Not found")

  defp error_msg(:no_response),
    do: dgettext("errors", "No response from Lexin API")
end
