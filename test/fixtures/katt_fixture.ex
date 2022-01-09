defmodule KattFixture do
  @moduledoc false

  def definitions() do
    [
      %Lexin.Definition{
        base: %Lexin.Definition.Lang{
          alternate: nil,
          antonyms: [],
          comment: nil,
          compounds: [],
          examples: [],
          idioms: [],
          illustrations: [
            %Lexin.Definition.Illustration{
              type: "picture",
              url:
                "https://bildetema.oslomet.no/bildetema/bildetema-html5/bildetema.html?version=swedish&languages=swe,rus&page=26&subpage=4"
            }
          ],
          inflections: [
            %Lexin.Definition.Content{id: nil, inflections: [], value: "katten"},
            %Lexin.Definition.Content{id: nil, inflections: [], value: "katter"}
          ],
          meaning: "husdjuret Felis ocreata domestica; kisse",
          phonetic: %Lexin.Definition.Phonetic{
            audio_url: "http://lexin.nada.kth.se/sound/v2/205567_1.mp3",
            transcription: "kat:"
          },
          synonyms: [],
          translation: nil
        },
        id: 8399,
        pos: "subst.",
        target: %Lexin.Definition.Lang{
          alternate: nil,
          antonyms: [],
          comment: nil,
          compounds: [],
          examples: [],
          idioms: [],
          illustrations: [],
          inflections: [],
          meaning: nil,
          phonetic: nil,
          synonyms: [],
          translation: "кот, кошка"
        },
        value: "katt"
      },
      %Lexin.Definition{
        base: %Lexin.Definition.Lang{
          alternate: "hanne",
          antonyms: [],
          comment: nil,
          compounds: [
            %Lexin.Definition.Content{id: 2803, inflections: [], value: "gorillahane"},
            %Lexin.Definition.Content{id: 2804, inflections: ["han|katten"], value: "han|katt"}
          ],
          examples: [],
          idioms: [],
          illustrations: [],
          inflections: [
            %Lexin.Definition.Content{id: nil, inflections: [], value: "hanen"},
            %Lexin.Definition.Content{id: nil, inflections: [], value: "hanar"}
          ],
          meaning: "djur av manligt kön",
          phonetic: %Lexin.Definition.Phonetic{
            audio_url: "http://lexin.nada.kth.se/sound/v2/179546_1.mp3",
            transcription: "²h'a:ne el. ²h'an:e"
          },
          synonyms: [],
          translation: nil
        },
        id: 6739,
        pos: "subst.",
        target: %Lexin.Definition.Lang{
          alternate: nil,
          antonyms: [],
          comment: nil,
          compounds: [
            %Lexin.Definition.Content{id: 2803, inflections: [], value: "самец гориллы"},
            %Lexin.Definition.Content{id: 2804, inflections: [], value: "кот"}
          ],
          examples: [],
          idioms: [],
          illustrations: [],
          inflections: [],
          meaning: nil,
          phonetic: nil,
          synonyms: [],
          translation: "самец"
        },
        value: "hane"
      },
      %Lexin.Definition{
        base: %Lexin.Definition.Lang{
          alternate: nil,
          antonyms: [],
          comment: nil,
          compounds: [],
          examples: [],
          idioms: [],
          illustrations: [],
          inflections: [
            %Lexin.Definition.Content{id: nil, inflections: [], value: "lussekatten"},
            %Lexin.Definition.Content{id: nil, inflections: [], value: "lussekatter"}
          ],
          meaning: "en slags vetebulle som äts på luciadagen",
          phonetic: %Lexin.Definition.Phonetic{
            audio_url: "http://lexin.nada.kth.se/sound/v2/232979_1.mp3",
            transcription: "²l'us:ekat:"
          },
          synonyms: [],
          translation: nil
        },
        id: 10_254,
        pos: "subst.",
        target: %Lexin.Definition.Lang{
          alternate: nil,
          antonyms: [],
          comment: nil,
          compounds: [],
          examples: [],
          idioms: [],
          illustrations: [],
          inflections: [],
          meaning: nil,
          phonetic: nil,
          synonyms: ["традиционное угощение в день Св. Люсии"],
          translation: "булочка с шафраном"
        },
        value: "lusse|katt"
      },
      %Lexin.Definition{
        base: %Lexin.Definition.Lang{
          alternate: nil,
          antonyms: [],
          comment: nil,
          compounds: [],
          examples: [],
          idioms: [],
          illustrations: [],
          inflections: [
            %Lexin.Definition.Content{id: nil, inflections: [], value: "solkatten"},
            %Lexin.Definition.Content{id: nil, inflections: [], value: "solkatter"}
          ],
          meaning: "solreflex från spegel",
          phonetic: %Lexin.Definition.Phonetic{
            audio_url: "http://lexin.nada.kth.se/sound/v2/333316_1.mp3",
            transcription: "²s'o:lkat:"
          },
          synonyms: [],
          translation: nil
        },
        id: 16_812,
        pos: "subst.",
        target: %Lexin.Definition.Lang{
          alternate: nil,
          antonyms: [],
          comment: nil,
          compounds: [],
          examples: [],
          idioms: [],
          illustrations: [],
          inflections: [],
          meaning: nil,
          phonetic: nil,
          synonyms: [],
          translation: "солнечный зайчик"
        },
        value: "sol|katt"
      },
      %Lexin.Definition{
        base: %Lexin.Definition.Lang{
          alternate: nil,
          antonyms: [],
          comment: nil,
          compounds: [%Lexin.Definition.Content{id: 7514, inflections: [], value: "kattunge"}],
          examples: [],
          idioms: [],
          illustrations: [],
          inflections: [
            %Lexin.Definition.Content{id: nil, inflections: [], value: "ungen"},
            %Lexin.Definition.Content{id: nil, inflections: [], value: "ungar"}
          ],
          meaning: "avkomma till djur",
          phonetic: %Lexin.Definition.Phonetic{
            audio_url: "http://lexin.nada.kth.se/sound/v2/376778_1.mp3",
            transcription: "²'ung:e"
          },
          synonyms: [],
          translation: nil
        },
        id: 19_821,
        pos: "subst.",
        target: %Lexin.Definition.Lang{
          alternate: nil,
          antonyms: [],
          comment: nil,
          compounds: [%Lexin.Definition.Content{id: 7514, inflections: [], value: "котёнок"}],
          examples: [],
          idioms: [],
          illustrations: [],
          inflections: [],
          meaning: nil,
          phonetic: nil,
          synonyms: [],
          translation: "детёныш"
        },
        value: "unge"
      }
    ]
  end
end
