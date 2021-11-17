defmodule LexinWeb.HelpController do
  use LexinWeb, :controller

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end
