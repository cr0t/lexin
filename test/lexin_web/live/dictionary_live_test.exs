defmodule LexinWeb.DictionaryLiveTest do
  use LexinWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @form_selector "form[phx-submit='submit']"

  describe "search" do
    test "allows to select a translation language", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form(@form_selector, lang: "russian", query: "a conto")
      |> render_submit()

      refute has_element?(view, "#flash-error")
    end

    test "pre-selects the given language in the URL", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/dictionary/a conto?lang=russian")

      assert has_element?(view, "#definition-5", "на мой счёт")
    end

    test "pre-selects the language in the URL even if another was saved", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/dictionary/a conto?lang=english")

      view
      |> form(@form_selector, query: "a conto")
      |> render_submit()

      assert has_element?(view, "#definition-5", "(in advance)")
    end

    test "shows an alert if wrong language is given in the URL", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/dictionary/a conto?lang=ruskii")

      assert has_element?(view, ".flash.is-error", "Språk stöds inte")
    end

    test "shows an alert if word not found", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form(@form_selector, lang: "russian", query: "hloogloo")
      |> render_submit()

      assert has_element?(view, ".flash.is-error", "Hittades inte")
    end

    test "shows definitions for the query", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form(@form_selector, lang: "russian", query: "a")
      |> render_submit()

      assert has_element?(view, "#definition-4", "sjätte tonen i C-durskalan")
      assert has_element?(view, "#definition-4", "ля")
    end

    test "switches definition to another available language", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form(@form_selector, lang: "russian", query: "a conto")
      |> render_submit()

      assert has_element?(view, "#definition-5", "А-конто")

      view
      |> element("#search_form-lang")
      |> render_change(%{lang: "english"})

      assert has_element?(view, "#definition-5", "on account")
    end

    test "shows all definition sections", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form(@form_selector, lang: "english", query: "bil")
      |> render_submit()

      assert has_element?(view, "#definition-1858", "bil, bilen, bilar, bil|trafiken")
      assert has_element?(view, "#definition-1858", "personbil — passenger car")
    end

    test "shows definitions of related words", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form(@form_selector, lang: "english", query: "bil")
      |> render_submit()

      assert has_element?(view, "#definition-918", "avgas [²A:vga:s]")
      assert has_element?(view, "#definition-918", "exhaust (gas)")
    end

    test "does not fail on reference-only definitions", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form(@form_selector, lang: "english", query: "silhuett")
      |> render_submit()

      assert has_element?(view, "#definition-15456", "silhuett se siluett")
      assert page_title(view) == "silhuett - silhouette"
    end

    test "shows query word in the page title", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert page_title(view) == "Lexin.mobi"

      view
      |> form(@form_selector, lang: "russian", query: "a conto")
      |> render_submit()

      assert page_title(view) == "a conto - А-конто"
    end

    test "shows a simplified page title when no translation available", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form(@form_selector, lang: "russian", query: "silhuett")
      |> render_submit()

      assert page_title(view) == "silhuett"
    end
  end
end
