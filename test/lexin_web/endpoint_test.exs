defmodule LexinWeb.EndpointTest do
  use ExUnit.Case, async: false

  import Plug.Test

  alias LexinWeb.Endpoint

  @limit Application.compile_env(:hammer, :limit)

  setup do
    :ets.delete_all_objects(Lexin.RateLimit)
    :ok
  end

  describe "rate_limit/2" do
    test "allows requests under the limit" do
      conn = build_conn_with_ip({1, 2, 3, 4}) |> Endpoint.rate_limit([])

      refute conn.halted
      assert conn.status != 429
    end

    test "blocks requests once the limit is exceeded for a given IP" do
      ip = {5, 6, 7, 8}

      for _ <- 1..@limit, do: build_conn_with_ip(ip) |> Endpoint.rate_limit([])

      conn = build_conn_with_ip(ip) |> Endpoint.rate_limit([])

      assert conn.halted
      assert conn.status == 429
    end

    test "tracks separate IPs independently" do
      conn_a = build_conn_with_ip({9, 9, 9, 1}) |> Endpoint.rate_limit([])
      conn_b = build_conn_with_ip({9, 9, 9, 2}) |> Endpoint.rate_limit([])

      refute conn_a.halted
      refute conn_b.halted
    end

    test "keys the limiter by conn.remote_ip" do
      build_conn_with_ip({203, 0, 113, 9}) |> Endpoint.rate_limit([])

      keys = :ets.tab2list(Lexin.RateLimit) |> Enum.map(fn {{key, _}, _, _} -> key end)

      assert Enum.any?(keys, &String.contains?(&1, "203.0.113.9"))
    end
  end

  defp build_conn_with_ip(ip),
    do: conn(:get, "/") |> Map.put(:remote_ip, ip)
end
