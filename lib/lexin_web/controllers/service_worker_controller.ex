defmodule LexinWeb.ServiceWorkerController do
  use LexinWeb, :controller

  def index(conn, _params) do
    conn
    |> Plug.Conn.put_private(:plug_skip_csrf_protection, true)
    |> render("index.js")
  end
end
