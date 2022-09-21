defmodule Lexin.StaticTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  import Wallaby.Query

  feature "opens about page", %{session: session} do
    session
    |> visit("/")
    |> click(link("About"))
    |> assert_has(
      css(".page_content",
        text:
          "We have built this little application to improve user experience for end users. The functionality this app provides is very basic: pick a language and search for the word. That's simple!"
      )
    )
  end

  feature "opens contacts page", %{session: session} do
    session
    |> visit("/")
    |> click(link("Contacts"))
    |> assert_has(
      css(".page_content",
        text:
          "Lexin Mobi is an open-source project, and you can find its code on GitHub. You are welcome to join the development process, or submit any feature requests or issues you find here."
      )
    )
    |> assert_has(
      css(".page_content",
        text: "You can contact the author of this app by email or via LinkedIn."
      )
    )
  end

  feature "opens installation page", %{session: session} do
    session
    |> visit("/")
    |> click(link("Install"))
    |> assert_has(
      css(".page_content",
        text:
          "You can use Lexin Mobi by opening it as a website in your favorite browser. (Psst... Save a bookmark for quick access!)"
      )
    )
    |> assert_has(
      css(".page_content",
        text:
          "You can also install and run Lexin Mobi as mobile application. See our step-by-step instructions on how to install this application to your iPhone/iPad. For Android-based devices installation process is similar, just do it using Chrome."
      )
    )
  end
end
