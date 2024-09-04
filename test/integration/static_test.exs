defmodule Lexin.StaticTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  import Wallaby.Query

  feature "opens about page", %{session: session} do
    session
    |> visit("/")
    |> click(link("About"))
    |> assert_has(
      css("main",
        text:
          "We made this small app to make it easier for users to use. It only does one thing: choose a language and search for a word. It does it very well!"
      )
    )
    |> assert_has(
      css("main",
        text:
          "Lexin.mobi is an open-source project, and you can find its source code on GitHub. You are welcome to contribute to the development process. This link can also be used to submit suggestions for enhancements or bugs, or to reach out to the developers of this application."
      )
    )
  end

  feature "opens installation page", %{session: session} do
    session
    |> visit("/")
    |> click(link("Install"))
    |> assert_has(
      css("main",
        text:
          "You can use Lexin.mobi as a website in your browser. To share a word definition with a friend or colleague – copy and send the currently opened URL. (Psst... Save a bookmark for quick access to this website!)"
      )
    )
    |> assert_has(
      css("main",
        text:
          "You can also install and run Lexin.mobi as mobile application. See our step-by-step instructions on how to install this application to your iPhone/iPad. For Android-based devices installation process is similar, but you need to use Chrome."
      )
    )
  end

  feature "opens cookies page", %{session: session} do
    session
    |> visit("/")
    |> click(link("Cookies"))
    |> assert_has(
      css("main",
        text: "Cookies are small files that websites put on your computer when you visit them."
      )
    )
    |> assert_has(
      css("main",
        text:
          "We only use cookies that we can control. We only use cookies that are needed to keep your session on our website running smoothly. Furthermore, we don't use cookies from other companies for tracking things like how people use our website."
      )
    )
  end
end
