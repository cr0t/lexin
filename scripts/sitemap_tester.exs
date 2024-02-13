defmodule SitemapTester do
  @moduledoc """
  Performs a simple operation for the generated (by `mix sitemap.gen`) sitemap files: it attempts
  to open every single URL from the files and collect statistics with the given response code, or
  possible failure. In the end, user gets a report with the numbers of succesfully opened links,
  and a list of ones with issues (not found, failed, and server errors).
  """

  require Logger

  @sitemaps_path Application.compile_env(:lexin, :sitemaps_path)

  def run() do
    "#{@sitemaps_path}/sitemap_*_*.xml"
    |> Path.wildcard()
    # |> Enum.take(2) # for speeding up the development
    |> Enum.map(&test/1)
    |> full_report()
  end

  defp test(sitemap_file) do
    Logger.info("Testing #{sitemap_file}...")

    urls =
      sitemap_file
      |> File.read!()
      |> Floki.parse_document!()
      |> Floki.find("loc")
      |> Enum.map(&Floki.text/1)

    # add the next replace to the chain above to test sitemaps against the localhost
    # |> Enum.map(&String.replace(&1, "https://lexin.mobi", "http://localhost:4000"))

    task_opts = [
      max_concurrency: System.schedulers_online(),
      on_timeout: :kill_task
    ]

    results =
      urls
      |> Task.async_stream(&test_url/1, task_opts)
      |> Enum.to_list()

    Logger.info("Done with #{sitemap_file}")

    {sitemap_file, Enum.count(urls), results}
  end

  defp test_url(url) do
    {:ok, {{_proto, code, status}, _, _}} =
      url
      |> URI.encode()
      |> :httpc.request()

    test_result =
      case code do
        200 -> :success
        404 -> :not_found
        _ -> List.to_atom(status)
      end

    {url, test_result}
  rescue
    _ -> {url, :failed}
  end

  defp full_report(results),
    do: Enum.map(results, &sitemap_report/1)

  defp sitemap_report({sitemap_file, total_urls, test_results}) do
    init = %{success: [], not_found: [], failed: []}

    stats =
      test_results
      |> Enum.map(&elem(&1, 1))
      |> Enum.reduce(init, fn {url, result}, acc ->
        Map.update(acc, result, [url], fn urls -> [url | urls] end)
      end)

    IO.puts("===\nReport on #{sitemap_file} with #{total_urls} total URLs:\n")

    # IO.inspect(stats)

    other =
      stats
      |> Enum.filter(fn
        {k, _} when k not in [:success, :not_found, :failed] -> true
        _ -> false
      end)
      |> Enum.into(%{})

    not_found = Enum.map(stats[:not_found], &"  - #{&1}\n")
    failed = Enum.map(stats[:failed], &"  - #{&1}\n")

    other_count = other |> Map.values() |> List.flatten() |> Enum.count()

    IO.puts("""
      - Success: #{Enum.count(stats[:success])}
      - Not found: #{Enum.count(stats[:not_found])}
      - Failed: #{Enum.count(stats[:failed])}
      - Other: #{other_count}
      ---
      Not found:

    #{not_found}
      ---
      Failed:

    #{failed}
      ---
      Other:

      #{inspect(other)}
    """)
  end
end

SitemapTester.run()
