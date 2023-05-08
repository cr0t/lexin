defmodule Lexin.SearchTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  import Wallaby.Query

  @query_input css("#form-query_field")
  @lang_select css("#form-lang")
  @submit_button css("#form-submit_button")

  feature "shows alert if no language is chosen", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@query_input, with: "a conto")
    |> click(@submit_button)
    |> assert_has(css(".alert.alert-danger", text: "Språk stöds inte"))
  end

  feature "allows to select a translation language", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "ryska")
    |> fill_in(@query_input, with: "a conto")
    |> click(@submit_button)
    |> refute_has(css(".alert.alert-danger"))
  end

  feature "shows definitions for the query", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "ryska")
    |> fill_in(@query_input, with: "a conto")
    |> click(@submit_button)
    |> assert_has(css("#definition-5", text: "i förskott"))
    |> assert_has(css("#definition-5", text: "А-конто"))
    |> assert_has(css("#definition-5", text: "(на мой счёт)"))
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
    |> assert_has(css("#definition-1858", text: "bil [bi:l] lyssna subst."))
    |> assert_has(css("#definition-1858", text: "<bil, bilen, bilar, bil|trafiken>"))
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
    |> assert_has(css("#definition-1858", text: "picture →"))
  end

  feature "shows definitions of related words", %{session: session} do
    session
    |> visit("/")
    |> fill_in(@lang_select, with: "engelska")
    |> fill_in(@query_input, with: "bil")
    |> click(@submit_button)
    |> assert_has(css("#definition-1858", text: "bil [bi:l] lyssna subst."))
    |> assert_has(css("#definition-918", text: "avgas [²A:vga:s] lyssna subst."))
    |> assert_has(
      css("#definition-918", text: "<avgas, avgasen, avgaser, avgas|reningen, avgas|systemet>")
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
        page_title(session) === "a conto · Lexin Mobi",
        "when user submits a query, we show it in the page's title"
      )
    end)
  end
end
