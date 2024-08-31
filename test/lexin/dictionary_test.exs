defmodule Lexin.DictionaryTest do
  use ExUnit.Case, async: true

  alias Lexin.Dictionary

  # For the available language dictionaries (and words in them), please check test/fixtures directory.

  describe "definitions" do
    test "returns list of definitions for the supported language and available word" do
      {:ok, definitions} = Dictionary.definitions("english", "bil")

      assert length(definitions) == 2
    end

    test "returns error if language is not supported" do
      assert {:error, :language_not_supported} = Dictionary.definitions("nolang", "bil")
    end

    test "returns error if word is not available" do
      assert {:error, :not_found} = Dictionary.definitions("english", "noword")
    end
  end

  describe "suggestions" do
    test "returns list of suggestions for the supported language and by the beginning of the word" do
      assert Dictionary.suggestions("english", "bi") ==
               ~w[bil bilen bilar bilfri bilsjuk bilburen bilsjuka biltrafik]

      assert Dictionary.suggestions("english", "la") == ~w[lastbil]
    end

    test "returns error if language is not supported" do
      assert {:error, :language_not_supported} = Dictionary.suggestions("nolang", "bi")
    end

    test "returns an empty list instead of error when nothing is found" do
      assert Dictionary.suggestions("english", "noword") == []
    end
  end

  describe "languages" do
    test "lists languages available at the boot of the app" do
      assert Dictionary.languages() == ["english", "russian"]
    end
  end
end
