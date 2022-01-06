defmodule LexinWeb.PagesController do
  use LexinWeb, :controller

  def about(conn, _params),
    do: render(conn, "about.html")

  def help(conn, _params),
    do: render(conn, "help.html")
end
