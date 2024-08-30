defmodule LexinWeb.CardComponents do
  @moduledoc """
  Provides partials for the definition results view.
  """

  use Phoenix.Component
  use LexinWeb, :html

  import Lexin.Dictionary.Helpers

  embed_templates("card/*")

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
    <.link patch={~p"/dictionary/#{@word}?lang=#{@lang}"}>
      <%= @word %>
    </.link>
    """
  end

  @doc """
  An anchor tag that plays the given audio file URL when user clicks. We duplicate the URL in the
  `href` attribute, so users can download files or listen in the other way if browser doesn't support
  `playAudio` JS feature.

  In rare cases `file` can be nil: we do not render the 'listen' button then.
  """
  attr :file, :string

  def listen_link(assigns) do
    ~H"""
    <button :if={@file} class="btn--listen" onclick={"playAudio('#{external_audio_url(@file)}')"}>
      <.icon name="hero-speaker-wave-solid" class="h-3 w-3 mr-1" />
      <%= gettext("listen") %>
    </button>
    """
  end
end
