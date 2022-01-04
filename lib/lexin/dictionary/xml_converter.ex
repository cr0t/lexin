defmodule Lexin.Dictionary.XMLConverter do
  @moduledoc """
  In order to get quick lookups for the words in the dictionary files, we want to convert original
  XML files into similar SQLite counterparts with simple structure.

  Every word definition might have referential `Index`-es – the words that can point to the main
  one. We should consider these variants when users search for the words.

  The same spelling of the word can be references in multiple definitions (check "a", for example),
  so we need a two-tables structure in our SQLite dictionary files; here is its basic structure:

  | definitions      |
  |------------------|
  | id INTEGER       | <---     | vocabulary            |
  | word TEXT        |     |    |-----------------------|
  | definition TEXT  |     |    | id INTEGER            |
                            --- | definition_id INTEGER |
                                | word TEXT             |
                                | type TEXT             |

  In the `definition` field we store the original XML snippet from the input XML file. In the
  `word` field of `definitions` table we store translation of the word (it is needed to let users
  type their queries in any language – it can be both in Swedish or in other language).

  Note: `Floki.raw_html/1` that we use in the code makes all original XML tag names downcased.

  The `vocabulary` table contains Swedish variants of the words and helps us to do fast lookups
  (10-15ms for the set of ~100k words in the table) and find corresponding definitions, which we
  lately might render to the user.

  Here is an example of SQL-query we can use to get definitions:

  ```sql
  SELECT DISTINCT definition FROM definitions
  JOIN vocabulary ON definitions.id = vocabulary.definition_id
  WHERE vocabulary.word LIKE 'fordon' OR definitions.translation LIKE 'fordon'
  ```

  In addition, these tables can also be used to generate suggestions to the input field while user
  is typing a search query.

  Here is an example of SQL-query we can use to get Swedish suggestions (similar to target lang):

  ```sql
  SELECT DISTINCT word FROM vocabulary
  ```

  Here is the way to prepare these `.sqlite` files which can be consumed later by the Lexin application:

  ```console
  mix run scripts/converter.exs --input swe_rus.xml --output russian.sqlite
  ```

  P.S. We need to check and be careful of words that spell the same way in both languages – should
  we show all definitions then? Maybe yes, maybe not.
  """

  @doc """
  Parse input XML, find all words' definitions and indexable references (variants of the word to
  lookup for), prepare database and insert converted data.
  """
  def convert(input_filename, output_filename) do
    IO.puts("Resetting database...")

    conn = reset_db!(output_filename)

    IO.puts("Parsing input XML...")

    all_words =
      input_filename
      |> parse_xml()

    IO.puts("Inserting into SQLite...")

    all_words
    |> Enum.reduce({conn, Enum.count(all_words), 0}, &insert/2)

    IO.puts("\nDone!")
  end

  defp reset_db!(output_filename) do
    File.rm(output_filename)

    {:ok, conn} = Exqlite.Sqlite3.open(output_filename)

    vocabulary_table = """
    CREATE TABLE "vocabulary" ("id" INTEGER PRIMARY KEY, "definition_id" INTEGER, "word" TEXT, "type" TEXT);
    """

    :ok = Exqlite.Sqlite3.execute(conn, vocabulary_table)

    definitions_table = """
    CREATE TABLE "definitions" ("id" INTEGER PRIMARY KEY, "word" TEXT, "definition" TEXT);
    """

    :ok = Exqlite.Sqlite3.execute(conn, definitions_table)

    conn
  end

  defp parse_xml(input_filename) do
    input_filename
    |> File.read!()
    |> Floki.parse_document!()
    |> Floki.find("word")
    |> Enum.map(&parse_word/1)
  end

  defp parse_word(word_block) do
    id =
      word_block
      |> Floki.attribute("variantid")
      |> List.first()
      |> String.to_integer()


    variants =
      for index <- Floki.find(word_block, "index") do
        {
          Floki.attribute(index, "value") |> List.first(),
          Floki.attribute(index, "type") |> List.first()
        }
      end

    word = Floki.find(word_block, "translation") |> Floki.text()
    definition = Floki.raw_html(word_block)

    {id, variants, word, definition}
  end

  defp insert({id, variants, word, definition}, {conn, total, processed}) do
    Enum.map(variants, fn {word, type} ->
      word_sql = "INSERT INTO vocabulary (definition_id, word, type) VALUES (?1, ?2, ?3)"

      {:ok, statement} = Exqlite.Sqlite3.prepare(conn, word_sql)
      :ok = Exqlite.Sqlite3.bind(conn, statement, [id, word, type])
      :done = Exqlite.Sqlite3.step(conn, statement)
    end)

    definition_sql = "INSERT INTO definitions (id, word, definition) VALUES (?1, ?2, ?3)"

    {:ok, statement} = Exqlite.Sqlite3.prepare(conn, definition_sql)
    :ok = Exqlite.Sqlite3.bind(conn, statement, [id, word, definition])
    :done = Exqlite.Sqlite3.step(conn, statement)

    # a simple "progress bar"
    IO.write("#{processed + 1} / #{total}\r")

    {conn, total, processed + 1}
  end
end
