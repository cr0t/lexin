defmodule LexinWeb.PagesController do
  use LexinWeb, :controller

  def contact(conn, _params),
    do: render(conn, "contact.html")

  def about(conn, _params),
    do: render(conn, "about.html")

  def help(conn, _params),
    do: render(conn, "help.html")
end
