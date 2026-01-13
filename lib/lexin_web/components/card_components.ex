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
          {gettext("watch film")}
        </a>
      </span>
    <% end %>
    """
  end

  def references(%{type: :compare} = assigns) do
    ~H"""
    <%= for word <- @values do %>
      <span>
        {gettext("compare")} <.reference_link word={"#{word}"} lang={@lang} />
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
  A searchable (in Lexin.mobi) link to the word and target language.
  """
  attr :word, :string, required: true
  attr :lang, :string, required: true

  def reference_link(assigns) do
    ~H"""
    <.link patch={~p"/dictionary/#{@word}?lang=#{@lang}"}>
      {@word}
    </.link>
    """
  end

  @doc """
  An anchor tag that plays the given audio file URL when user clicks it.

  We duplicate the URL in the `href` attribute, so users can simply download linked file and listen
  to it some other way, e.g., if browser doesn't support the `Audio` feature (which is unlikely).

  In rare cases `file` can be nil: we do not render the 'listen' link then.
  """
  attr :file, :string

  def listen_link(assigns) do
    ~H"""
    <a
      :if={@file}
      class="listen"
      href={external_audio_url(@file)}
      onclick={"new Audio('#{external_audio_url(@file)}').play(); return false"}
    >
      🔉 {gettext("listen")}
    </a>
    """
  end
end
