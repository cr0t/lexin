defmodule LexinWeb.PageController do
  use LexinWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
