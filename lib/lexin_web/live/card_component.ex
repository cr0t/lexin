defmodule LexinWeb.CardComponent do
  use Phoenix.LiveComponent

  def listen_handler(dfn) do
    "return playAudio('#{dfn.base.phonetic.audio_url}')"
  end

  def illustrations(dfn) do
    dfn.base.illustrations ++ dfn.target.illustrations
  end

  def inflections(dfn) do
    [dfn.value | Enum.map(dfn.base.inflections, &(&1.value))]
  end

  def examples(dfn) do
    Enum.zip(dfn.base.examples, dfn.target.examples)
  end

  def idioms(dfn) do
    Enum.zip(dfn.base.idioms, dfn.target.idioms)
  end

  def compounds(dfn) do
    Enum.zip(dfn.base.compounds, dfn.target.compounds)
  end
end
