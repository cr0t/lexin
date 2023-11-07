defmodule Lexin.SearchTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  import Wallaby.Query

  @query_input css("#form-query_field")
  @lang_select css("#form-lang")
  @submit_button css("#form-submit_button")

  feature "allows to select a translation language", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "ryska")
    |> fill_in(@query_input, with: "a conto")
    |> click(@submit_button)
    |> refute_has(css("#flash.flash--error"))
  end

  feature "pre-selects the given language in the URL", %{session: session} do
    session
    |> visit("/dictionary/a conto?lang=russian")
    |> assert_has(css("#definition-5", text: "на мой счёт"))
  end

  feature "pre-selects the previously saved language", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "ryska")
    |> visit("/")
    |> fill_in(@query_input, with: "a conto")
    |> click(@submit_button)
    |> assert_has(css("#definition-5", text: "на мой счёт"))
  end

  feature "pre-selects the language in the URL even is the other was saved", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "ryska")
    |> visit("/dictionary/a conto?lang=english")
    |> fill_in(@query_input, with: "a conto")
    |> click(@submit_button)
    |> assert_has(css("#definition-5", text: "(in advance)"))
  end

  feature "shows an alert if wrong language is given in the URL", %{session: session} do
    session
    |> visit("/dictionary/a conto?lang=ruskii")
    |> assert_has(css("#flash.flash--error", text: "Språk stöds inte"))
  end

  feature "shows an alert if word not found", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "ryska")
    |> fill_in(@query_input, with: "hloogloo")
    |> click(@submit_button)
    |> assert_has(css("#flash.flash--error", text: "Hittades inte"))
  end

  feature "shows definitions for the query", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "ryska")
    |> fill_in(@query_input, with: "a")
    |> click(@submit_button)
    |> assert_has(css("#definition-4", text: "sjätte tonen i C-durskalan"))
    |> assert_has(css("#definition-4", text: "ля"))
    |> assert_has(css("#definition-4", text: "(\"музыкальный термин (шестая нота гаммы)"))
  end

  feature "switches definition to another available language", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "ryska")
    |> fill_in(@query_input, with: "a conto")
    |> click(@submit_button)
    |> assert_has(css("#definition-5", text: "i förskott"))
    |> assert_has(css("#definition-5", text: "А-конто"))
    |> assert_has(css("#definition-5", text: "(на мой счёт)"))
    |> fill_in(@lang_select, with: "engelska")
    |> assert_has(css("#definition-5", text: "i förskott"))
    |> assert_has(css("#definition-5", text: "on account"))
    |> assert_has(css("#definition-5", text: "(in advance)"))
  end

  feature "shows all definition sections", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "engelska")
    |> fill_in(@query_input, with: "bil")
    |> click(@submit_button)
    |> assert_has(css("#definition-1858", text: "bil [bi:l]"))
    |> assert_has(css("#definition-1858", text: "lyssna"))
    |> assert_has(css("#definition-1858", text: "subst."))
    |> assert_has(css("#definition-1858", text: "bil, bilen, bilar, bil|trafiken"))
    |> assert_has(css("#definition-1858", text: "ett slags motordrivet fordon"))
    |> assert_has(css("#definition-1858", text: "car, motorcar, (automobile [US]), (auto [US])"))
    |> assert_has(css("#definition-1858", text: "Exempel"))
    |> assert_has(css("#definition-1858", text: "åka bil — go by car"))
    |> assert_has(css("#definition-1858", text: "Sammansättningar"))
    |> assert_has(css("#definition-1858", text: "bil|trafik bil|trafiken — motor traffic"))
    |> assert_has(css("#definition-1858", text: "personbil — passenger car"))
    |> assert_has(css("#definition-1858", text: "bil|buren — motorized"))
    |> assert_has(css("#definition-1858", text: "bil|fri — free of cars"))
    |> assert_has(css("#definition-1858", text: "bil|sjuk — carsick"))
    |> assert_has(css("#definition-1858", text: "bil|sjuka — carsickness"))
    |> assert_has(css("#definition-1858", text: "bil|telefon — car phone"))
    |> assert_has(css("#definition-1858", text: "lastbil — lorry, (truck [US])"))
    |> assert_has(css("#definition-1858", text: "Extra"))
    |> assert_has(css("#definition-1858", text: "picture"))
  end

  feature "shows definitions of related words", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "engelska")
    |> fill_in(@query_input, with: "bil")
    |> click(@submit_button)
    |> assert_has(css("#definition-1858", text: "bil [bi:l]"))
    |> assert_has(css("#definition-1858", text: "lyssna"))
    |> assert_has(css("#definition-1858", text: "subst."))
    |> assert_has(css("#definition-918", text: "avgas [²A:vga:s]"))
    |> assert_has(css("#definition-918", text: "lyssna"))
    |> assert_has(css("#definition-918", text: "subst."))
    |> assert_has(
      css("#definition-918", text: "avgas, avgasen, avgaser, avgas|reningen, avgas|systemet")
    )
    |> assert_has(css("#definition-918", text: "gas som bildas vid förbränning i motor"))
    |> assert_has(css("#definition-918", text: "Användning: mest i plural"))
    |> assert_has(css("#definition-918", text: "exhaust (gas)"))
    |> assert_has(
      css("#definition-918", text: "(the waste gas produced by internal combustion engines)")
    )
    |> assert_has(css("#definition-918", text: "Exempel"))
    |> assert_has(
      css("#definition-918",
        text: "trafiken medför buller och avgaser — traffic causes noise and pollution"
      )
    )
    |> assert_has(css("#definition-918", text: "Sammansättningar"))
    |> assert_has(css("#definition-918", text: "bilavgaser — exhaust fumes"))
    |> assert_has(
      css("#definition-918",
        text: "avgas|rening avgas|reningen — exhaust conversion, exhaust emission control"
      )
    )
    |> assert_has(css("#definition-918", text: "avgas|system avgas|systemet — exhaust system"))
    |> assert_has(css("#definition-918", text: "avgas|rör — exhaust pipe"))
  end

  feature "shows query word in the page title", %{session: session} do
    session
    |> visit("/")
    |> then(fn session ->
      assert(
        page_title(session) === "Lexin Mobi",
        "if query is empty, the title is default"
      )

      session
    end)
    |> fill_in(@lang_select, with: "ryska")
    |> fill_in(@query_input, with: "a conto")
    |> click(@submit_button)
    |> assert_has(css("#definition-5", text: "i förskott"))
    |> then(fn session ->
      assert(
        page_title(session) === "a conto - А-конто · Lexin Mobi",
        "when user submits a query, we show it in the page's title"
      )
    end)
  end
end
