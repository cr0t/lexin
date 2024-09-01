defmodule LexinWeb.SEO.ForDefinitionTest do
  use ExUnit.Case, async: true

  doctest LexinWeb.SEO.ForDefinition

  alias LexinWeb.SEO.ForDefinition

  describe "title" do
    test "returns simply a query value if there is no translation" do
      definition = %Lexin.Definition{
        id: 1,
        pos: 1,
        base: %Lexin.Definition.Lang{},
        target: %Lexin.Definition.Lang{},
        value: "lastbil"
      }

      params = %{"query" => "lastbil"}

      assert ForDefinition.title(definition, params) == "lastbil"
    end

    test "returns query value and translation when it's available" do
      definition = %Lexin.Definition{
        id: 1,
        pos: 1,
        base: %Lexin.Definition.Lang{},
        target: %Lexin.Definition.Lang{translation: "lorry, (truck [US])"},
        value: "lastbil"
      }

      params = %{"query" => "lastbil"}

      assert ForDefinition.title(definition, params) == "lastbil - lorry, (truck [US])"
    end
  end

  describe "description" do
    test "returns basic query value if no other information is available" do
      definition = %Lexin.Definition{
        id: 1,
        pos: 1,
        base: %Lexin.Definition.Lang{},
        target: %Lexin.Definition.Lang{},
        value: "silhuett"
      }

      params = %{"query" => "silhuett", "lang" => "russian"}

      assert ForDefinition.description(definition, params) == "(svenska) silhuett"
    end

    test "returns richer description if transcription, meaning, and translation are available" do
      definition = %Lexin.Definition{
        id: 1,
        pos: 1,
        base: %Lexin.Definition.Lang{
          meaning: "den vanligaste vätskan på jorden (i sjöar, hav etc), H2O",
          phonetic: %Lexin.Definition.Phonetic{transcription: "vAt:en", audio_url: "#"}
        },
        target: %Lexin.Definition.Lang{
          translation: "вода"
        },
        value: "vatten"
      }

      params = %{"query" => "vatten", "lang" => "russian"}

      assert ForDefinition.description(definition, params) ==
               "(svenska) vatten [vAt:en] - den vanligaste vätskan på jorden (i sjöar, hav etc), H2O; (russian) - вода"
    end
  end
end
