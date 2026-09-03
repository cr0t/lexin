defmodule LexinWeb.PagesControllerTest do
  use LexinWeb.ConnCase, async: true

  describe "static pages" do
    test "opens about page", %{conn: conn} do
      conn = get(conn, ~p"/about")
      html = html_response(conn, 200)

      assert html =~ "We made this small app to make it easier for users to use."
      assert html =~ "It only does one thing: choose a language and search for a word."
      assert html =~ "It does it very well!"
      assert html =~ "Lexin.mobi is an open-source project"
      assert html =~ "You are welcome to contribute to the development process."
    end

    test "opens installation page", %{conn: conn} do
      conn = get(conn, ~p"/install")
      html = html_response(conn, 200)

      assert html =~ "You can use Lexin.mobi as a"
      assert html =~ "in your browser. To share a word definition"
      assert html =~ "You can also install and run Lexin.mobi as mobile application."
      assert html =~ "For Android-based devices installation process is similar"
    end

    test "opens cookies page", %{conn: conn} do
      conn = get(conn, ~p"/cookies")
      html = html_response(conn, 200)

      assert html =~
               "Cookies are small files that websites put on your computer when you visit them."

      assert html =~ "We only use cookies that we can control."
    end
  end
end
