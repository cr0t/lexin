defmodule Lexin.Dictionary.Files do
  @moduledoc false

  @sqlite_ext ".sqlite"

  @doc """
  Returns a list of available .sqlite files in the dictionaries directory.

  Expects to get the directory via Application environment variables.
  """
  @spec available() :: Map.t()
  def available() do
    app_root = Application.app_dir(:lexin)
    dic_path = Application.get_env(:lexin, :dictionaries_path)

    [app_root, dic_path, "*#{@sqlite_ext}"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.map(fn file_path ->
      lang = file_path |> Path.rootname(@sqlite_ext) |> Path.basename()

      {lang, file_path}
    end)
    |> Map.new()
  end
end
