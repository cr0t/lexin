defmodule Lexin.XMLConverter do
  @moduledoc """
  In order to get quick lookups for the words in the dictionary files, we want to convert original
  XML files into similar SQLite counterparts with simple structure.

  Every word definition might have referential `Index`-es – the words that can point to the main
  one. We should consider these variants when users search for the words.

  The same spelling of the word can be references in multiple definitions (check "a", for example),
  so we need a two-tables structure in our SQLite dictionary files; here is its basic structure:

  | definitions     |
  |-----------------|
  | id INTEGER      | <---      | vocabulary            |
  | definition TEXT |     |     |-----------------------|
                          |     | id INTEGER            |
                           ---- | definition_id INTEGER |
                                | word TEXT             |
                                | type TEXT             |

  In the `definition` field we store the original XML snippet from the input XML file.

  Note: `Floki.raw_html/1` that we use in the code makes all original XML tag names downcased.

  The `vocabulary` table helps us to do fast lookups (10-15ms for the set of ~100k words in the
  table) and find corresponding definitions, which we lately might render to the user.

  Here is an example SQL-query we can use:

  ```sql
  SELECT definition FROM definitions
  JOIN vocabulary ON definitions.id = vocabulary.definition_id
  WHERE vocabulary.word LIKE "fordon"
  ```
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
    {:ok, conn} = Exqlite.Sqlite3.open(output_filename)

    vocabulary_table = """
    BEGIN;
    DROP TABLE IF EXISTS "vocabulary";
    CREATE TABLE "vocabulary" ("id" INTEGER PRIMARY KEY, "definition_id" INTEGER, "word" TEXT, "type" TEXT);
    COMMIT;
    """

    :ok = Exqlite.Sqlite3.execute(conn, vocabulary_table)

    definitions_table = """
    BEGIN;
    DROP TABLE IF EXISTS "definitions";
    CREATE TABLE "definitions" ("id" INTEGER PRIMARY KEY, "definition" TEXT);
    COMMIT;
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

  defp parse_word(word) do
    id =
      word
      |> Floki.attribute("variantid")
      |> List.first()
      |> String.to_integer()


    variants =
      for index <- Floki.find(word, "index") do
        {
          Floki.attribute(index, "value") |> List.first(),
          Floki.attribute(index, "type") |> List.first()
        }
      end

    definition = Floki.raw_html(word)

    {id, variants, definition}
  end

  defp insert({id, variants, definition}, {conn, total, processed}) do
    Enum.map(variants, fn {word, type} ->
      word_sql = "INSERT INTO vocabulary (definition_id, word, type) VALUES (?1, ?2, ?3)"

      {:ok, statement} = Exqlite.Sqlite3.prepare(conn, word_sql)
      :ok = Exqlite.Sqlite3.bind(conn, statement, [id, word, type])
      :done = Exqlite.Sqlite3.step(conn, statement)
    end)

    definition_sql = "INSERT INTO definitions (id, definition) VALUES (?1, ?2)"

    {:ok, statement} = Exqlite.Sqlite3.prepare(conn, definition_sql)
    :ok = Exqlite.Sqlite3.bind(conn, statement, [id, definition])
    :done = Exqlite.Sqlite3.step(conn, statement)

    # a simple "progress bar"
    IO.write("#{processed + 1} / #{total}\r")

    {conn, total, processed + 1}
  end
end
