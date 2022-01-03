defmodule XMLConverterRunner do
  @moduledoc """
  CLI wrapper to Lexin.XMLConverter module
  """

  @doc """
  Run this script using `mix` (because is uses a module defined in the app). For example:

  mix run scripts/converter.exs --input swe_rus.xml --output swe_rus.sqlite
  """
  def main(args \\ []) do
    {options, _} = OptionParser.parse!(args, strict: [input: :string, output: :string])

    case options do
      [input: input_filename, output: output_filename] ->
        Lexin.XMLConverter.convert(input_filename, output_filename)

      _ ->
        usage()
        exit({:shutdown, 1})
    end
  end

  defp usage() do
    """
    Lexin XML to SQLite Converter

    Usage: mix run scripts/converter.exs --input swe_rus.xml --output swe_rus.sqlite
    """
    |> String.trim()
    |> IO.puts()
  end
end

System.argv()
|> XMLConverterRunner.main()
