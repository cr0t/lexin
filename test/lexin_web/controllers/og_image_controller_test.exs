defmodule LexinWeb.OGImageControllerTest do
  use LexinWeb.ConnCase, async: true

  # For the available language dictionaries (and words in them), please check test/fixtures directory.

  describe "image" do
    test "renders not_found when language is not supported", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, ~p"/share/og/nolang/bil")
      end
    end

    test "renders not_found when query is not in the dictionary", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, ~p"/share/og/english/noword")
      end
    end

    test "renders a PNG image", %{conn: conn} do
      conn = get(conn, ~p"/share/og/english/bil")

      # Thanks Exercism's File Sniffer task for the assertion idea:
      # https://exercism.org/tracks/elixir/exercises/file-sniffer.

      assert ["image/png; charset=utf-8"] = get_resp_header(conn, "content-type")
      assert <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>> = conn.resp_body
    end
  end
end