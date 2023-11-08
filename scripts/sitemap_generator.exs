defmodule SitemapGenerator do
  @moduledoc """
  Generates static sitemap.xml files for all available dictionaries.

  Following the Google Search Central recommendations, we also:

  - split sitemaps per language
  - split them by maximum 50K locations per file
  - name the splits accordingly

  > See for more information:
  >
  > https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap

  We can run this file by `mix sitemap` from the project's root.

  When generation finishes, it prints a report, so developer must check the robots.txt file.
  """

  alias Exqlite.Sqlite3, as: SQLite
  alias Lexin.Dictionary.Data

  require Logger

  @url_prefix "https://lexin.mobi"
  @static_path Path.join(["priv", "static"])
  @max_urls_per_file 50_000

  def generate() do
    Data.load_dictionaries()
    |> Enum.map(&make_sitemap/1)
    |> List.flatten()
    |> then(fn sitemap_files ->
      sitemap_files
      |> compile_sitemapindex()
      |> save_to_file!("sitemap.xml")

      report(sitemap_files)
    end)
  end

  defp make_sitemap({lang, db}) do
    Logger.info("Generating sitemap(s) for #{lang}...")

    db
    |> vocabulary()
    |> Enum.map(&url_for(&1, lang))
    |> Enum.chunk_every(@max_urls_per_file)
    |> Enum.with_index()
    |> Enum.reduce([], &persist_sitemap({&1, lang}, &2))
  end

  defp vocabulary(db) do
    vocab_query = "SELECT DISTINCT(word) FROM vocabulary"

    with {:ok, statement} <- SQLite.prepare(db, vocab_query),
         {:ok, rows} <- SQLite.fetch_all(db, statement),
         :ok <- SQLite.release(db, statement) do
      List.flatten(rows)
    end
  end

  defp url_for(word, lang) do
    word = String.replace(word, "/", "%2F")

    URI.encode("#{@url_prefix}/dictionary/#{word}?lang=#{lang}")
  end

  defp persist_sitemap({{urls, chunk_n}, lang}, filenames) do
    filename = "sitemap_#{lang}_#{chunk_n}.xml"

    urls
    |> compile_sitemap()
    |> save_to_file!(filename)

    [filename | filenames]
  end

  defp compile_sitemap(urls) do
    intro = """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    """

    outro = "\n</urlset>\n"

    urls
    |> Enum.map(&"<url><loc>#{&1}</loc></url>")
    |> Enum.join("\n")
    |> then(&"#{intro}#{&1}#{outro}")
  end

  defp compile_sitemapindex(sitemap_files) do
    intro = """
    <?xml version="1.0" encoding="UTF-8"?>
    <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    """

    outro = "\n</sitemapindex>\n"

    sitemap_files
    |> Enum.map(&"#{@url_prefix}/#{&1}")
    |> Enum.map(&"<sitemap><loc>#{&1}</loc></sitemap>")
    |> Enum.join("\n")
    |> then(&"#{intro}#{&1}#{outro}")
  end

  defp report(sitemap_files) do
    list_of_sitemaps = sitemap_files |> Enum.sort() |> Enum.join("\n")

    IO.puts("""
    =====
    We have generated these sitemap files:

    #{list_of_sitemaps}

    ...as well as the sitemap index file that shall list all of them.
    """)

    IO.puts("""
    Ensure that it defines all of the and your robots.txt looks like this:

    User-agent: *

    Sitemap: #{@url_prefix}/sitemap.xml
    """)
  end

  defp save_to_file!(contents, filename) do
    [@static_path, filename]
    |> Path.join()
    |> File.write!(contents)
  end
end

SitemapGenerator.generate()
