defmodule LexinWeb.SEO do
  @moduledoc """
  Squeezes some Search Engine Optimization juice to our pages.
  """

  use LexinWeb, :verified_routes

  @default_desc "A combination of a Swedish vocabulary and a dictionary developed for use in the multinational society of Sweden and rest of the world."
  @default_title "Lexin.mobi"
  @default_image "/images/og_default.png"

  use SEO,
    json_library: Jason,
    site: &__MODULE__.site_config/1,
    open_graph: &__MODULE__.open_graph_config/1

  def site_config(_conn) do
    SEO.Site.build(
      default_title: @default_title,
      description: @default_desc,
      manifest_url: ~p"/manifest.webmanifest"
    )
  end

  def open_graph_config(conn) do
    SEO.OpenGraph.build(
      description: @default_desc,
      site_name: @default_title,
      image: static_url(conn, @default_image)
    )
  end
end
