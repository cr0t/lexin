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

  require Logger

  @url_prefix "https://lexin.mobi"
  @static_path Path.join(["sitemaps"])
  @max_urls_per_file 50_000

  def generate!() do
    case Lexin.Dictionary.Data.load_dictionaries() do
      dicts when map_size(dicts) == 0 ->
        raise "Cannot find any dictionary file! Please, provide language databases to generate sitemaps..."

      dicts ->
        compile(dicts)
    end
  end

  def compile(dictionaries) do
    dictionaries
    |> Enum.map(&make_sitemap/1)
    |> List.flatten()
    |> then(fn sitemap_files ->
      sitemap_files
      |> build_sitemapindex()
      |> save_to_file!("sitemap.xml")

      report(sitemap_files)
    end)
  end

  defp make_sitemap({lang, db}) do
    Logger.info("Generating sitemap(s) for #{lang}...")

    db
    |> get_vocabulary()
    |> Enum.map(&url_for(&1, lang))
    |> Enum.chunk_every(@max_urls_per_file)
    |> Enum.with_index()
    |> Enum.reduce([], &persist_sitemap({&1, lang}, &2))
  end

  defp get_vocabulary(db) do
    vocab_query = "SELECT DISTINCT(word) FROM vocabulary"

    with {:ok, statement} <- SQLite.prepare(db, vocab_query),
         {:ok, rows} <- SQLite.fetch_all(db, statement),
         :ok <- SQLite.release(db, statement) do
      List.flatten(rows)
    end
  end

  defp url_for(word, lang) do
    # some of the words might have `/` character inside
    word = String.replace(word, "/", "%2F")

    [@url_prefix, "/dictionary/", word, "?lang=", lang]
    |> IO.iodata_to_binary()
    |> URI.encode()
  end

  defp persist_sitemap({{urls, chunk_n}, lang}, filenames) do
    filename = "sitemap_#{lang}_#{chunk_n}.xml"

    urls
    |> build_sitemap()
    |> save_to_file!(filename)

    [filename | filenames]
  end

  defp build_sitemap(urls) do
    intro = """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    """

    outro = "</urlset>\n"

    locations = Enum.map(urls, &["<url><loc>", &1, "</loc></url>\n"])

    IO.iodata_to_binary([intro, locations, outro])
  end

  defp build_sitemapindex(sitemap_files) do
    intro = """
    <?xml version="1.0" encoding="UTF-8"?>
    <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    """

    outro = "</sitemapindex>\n"

    sitemap_files_urls =
      Enum.map(sitemap_files, &["<sitemap><loc>", @url_prefix, "/", &1, "</loc></sitemap>\n"])

    IO.iodata_to_binary([intro, sitemap_files_urls, outro])
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

SitemapGenerator.generate!()
