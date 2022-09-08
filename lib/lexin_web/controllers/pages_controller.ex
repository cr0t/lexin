defmodule LexinWeb.PagesController do
  use LexinWeb, :controller

  def contact(conn, _params),
    do: render(conn, "contact.html")

  def about(conn, _params),
    do: render(conn, "about.html")

  def install(conn, _params),
    do: render(conn, "install.html")
end
