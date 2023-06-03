defmodule LexinWeb.SerpComponents do
  @moduledoc """
  Provides partials and view helpers for "Search Results Page".
  """

  use Phoenix.Component
  use LexinWeb, :html

  import LexinWeb.Gettext

  embed_templates("cards/*")

  @audio_url_prefix Application.compile_env(:lexin, :external_audio_url_prefix, "")
  @video_url_prefix Application.compile_env(:lexin, :external_video_url_prefix, "")
  @picture_url_prefix Application.compile_env(:lexin, :external_picture_url_prefix, "")

  @picture_languages_map %{
    "albanian" => "swe,sqi",
    "amharic" => "swe,amh",
    "arabic" => "swe,ara",
    "azerbaijani" => "swe",
    "bosnian" => "swe,bos",
    "english" => "swe,eng",
    "finnish" => "swe,fin",
    "greek" => "swe,ell",
    "croatian" => "swe",
    "northern_kurdish" => "swe,kmr",
    "pashto" => "swe",
    "persian" => "swe,fas",
    "russian" => "swe,rus",
    "serbian_latin" => "swe",
    "serbian_cyrillic" => "swe",
    "somali" => "swe,som",
    "spanish" => "swe,spa",
    "swedish" => "swe",
    "southern_kurdish" => "swe,sdh",
    "tigrinya" => "swe,tir",
    "turkish" => "swe,tur"
  }

  ###
  # Components
  ###

  @doc """
  Represents a definition "card" template, provides a few useful helpers to render the data.
  """
  attr :dfn, :map, required: true
  attr :target_lang, :string, required: true

  def definition(assigns)

  @doc """
  References links
  """
  attr :type, :atom, required: true
  attr :values, :list, default: []
  attr :lang, :string, required: true

  def references(%{type: :animation} = assigns) do
    ~H"""
    <%= for path <- @values do %>
      <span>
        <a href={external_video_url(path)} target="_blank">
          <%= gettext("watch film") %>
          <.icon name="hero-arrow-top-right-on-square-mini" class="h-3 w-3" />
        </a>
      </span>
    <% end %>
    """
  end

  def references(%{type: :compare} = assigns) do
    ~H"""
    <%= for word <- @values do %>
      <span>
        <%= gettext("compare") %> <.reference_link word={"#{word}"} lang={@lang} />
      </span>
    <% end %>
    """
  end

  def references(%{type: :phonetic} = assigns) do
    ~H"""
    <%= for file_path <- @values do %>
      <span>
        <.listen_link file={"#{file_path}"} />
      </span>
    <% end %>
    """
  end

  def references(%{type: :see} = assigns) do
    ~H"""
    <%= for word <- @values do %>
      <span>
        <.reference_link word={word} lang={@lang} />
      </span>
    <% end %>
    """
  end

  @doc """
  A searchable (in Lexin Mobi) link to the word and target language.
  """
  attr :word, :string, required: true
  attr :lang, :string, required: true

  def reference_link(assigns) do
    ~H"""
    <a href={~p"/?query=#{@word}&lang=#{@lang}"}><%= @word %></a>
    """
  end

  @doc """
  An anchor tag that plays the given audio file URL when user clicks. We duplicate the URL in the
  `href` attribute, so users can download files or listen in the other way if browser doesn't support
  `playAudio` JS feature.
  """
  attr :file, :string, required: true

  def listen_link(assigns) do
    ~H"""
    <button class="btn--listen" onclick={"playAudio('#{external_audio_url(@file)}')"}>
      <.icon name="hero-speaker-wave-solid" class="h-3 w-3 mr-1" />
      <%= gettext("listen") %>
    </button>
    """
  end

  ###
  # Little Santa's Helpers
  ###

  defp graminfo(dfn),
    do: dfn.base.graminfo |> String.replace("&", dfn.value)

  defp illustrations(dfn),
    do: dfn.base.illustrations ++ dfn.target.illustrations

  defp inflections(dfn),
    do: [dfn.value | Enum.map(dfn.base.inflections, & &1.value)]

  defp examples(dfn),
    do: Enum.zip(dfn.base.examples, dfn.target.examples)

  defp idioms(dfn),
    do: Enum.zip(dfn.base.idioms, dfn.target.idioms)

  defp compounds(dfn),
    do: Enum.zip(dfn.base.compounds, dfn.target.compounds)

  defp derivations(dfn),
    do: Enum.zip(dfn.base.derivations, dfn.target.derivations)

  defp external_audio_url(path),
    do: "#{@audio_url_prefix}#{path}"

  defp external_video_url(path),
    do: "#{@video_url_prefix}#{path}"

  defp external_picture_url(picture_params, target_lang) do
    langs_value = Map.get(@picture_languages_map, target_lang, "swe,swe")
    languages = "languages=#{langs_value}"

    "#{@picture_url_prefix}&#{languages}&#{picture_params}"
  end
end
