defmodule LexinWeb.DictionaryLive do
  use LexinWeb, :live_view

  import LexinWeb.Gettext

  alias LexinWeb.CardComponent

  def mount(_params, _session, socket) do
    socket =
      assign(socket, %{
        query: "katt",
        definitions: KattFixture.definitions()
      })

    {:ok, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    socket =
      assign(socket, %{
        query: query,
        definitions: find_definitions(query)
      })

    {:noreply, socket}
  end

  defp find_definitions(query), do: Lexin.Service.lookup(query)
end
