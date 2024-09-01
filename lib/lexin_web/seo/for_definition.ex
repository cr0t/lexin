defmodule LexinWeb.SEO.ForDefinition do
  @moduledoc """
  Provides a few SEO helpers for sharing.
  """

  def title(definition, %{"query" => query}) do
    case get_in(definition.target.translation) do
      nil -> definition.value
      translation -> "#{query} - #{translation}"
    end
  end

  def description(definition, %{"query" => query, "lang" => lang}) do
    transcription =
      case get_in(definition.base.phonetic.transcription) do
        nil -> ""
        value -> " [#{value}]"
      end

    meaning =
      case get_in(definition.base.meaning) do
        nil -> ""
        value -> " - #{value}"
      end

    translation =
      case get_in(definition.target.translation) do
        nil -> ""
        value -> "; (#{lang}) - #{value}"
      end

    Enum.join(["(svenska) #{query}", transcription, meaning, translation])
  end
end

defimpl SEO.Site.Build, for: Lexin.Definition do
  def build(definition, conn) do
    SEO.Site.build(
      title: LexinWeb.SEO.ForDefinition.title(definition, conn.params),
      description: LexinWeb.SEO.ForDefinition.description(definition, conn.params)
    )
  end
end

defimpl SEO.OpenGraph.Build, for: Lexin.Definition do
  use LexinWeb, :verified_routes

  def build(definition, conn) do
    SEO.OpenGraph.build(
      title: LexinWeb.SEO.ForDefinition.title(definition, conn.params),
      image: SEO.OpenGraph.Image.build(url: og_image_url(conn)),
      description: LexinWeb.SEO.ForDefinition.description(definition, conn.params)
    )
  end

  defp og_image_url(conn) do
    %{"lang" => lang, "query" => query} = conn.params

    url(conn, ~p"/share/og/#{lang}/#{query}")
  end
end
