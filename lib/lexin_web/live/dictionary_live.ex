defmodule LexinWeb.DictionaryLive do
  use LexinWeb, :live_view

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
      assign(socket, %{
        query: query,
        definitions: find_definitions(query)
      })

    {:noreply, socket}
  end

  defp find_definitions(_query), do: []
end
