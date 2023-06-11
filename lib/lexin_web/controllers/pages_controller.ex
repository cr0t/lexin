defmodule LexinWeb.PagesController do
  use LexinWeb, :controller

  def about(conn, _params),
    do: render(conn, :about)

  def cookies(conn, _params),
    do: render(conn, :cookies)

  def install(conn, _params),
    do: render(conn, :install)
end
