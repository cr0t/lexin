defmodule LexinWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """

  use Phoenix.Component
  use Gettext, backend: LexinWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "flash--container",
        @kind == :info && "flash--info",
        @kind == :error && "flash--error"
      ]}
      {@rest}
    >
      <div class="flex items-start justify-between">
        <div class="flex flex-col basis-full">
          <div :if={@title} class="gap-1 my-1 text-sm font-semibold">
            {@title}
          </div>
          <div class="my-1 text-base">
            {msg}
          </div>
        </div>

        <button type="button" class="group flex self-center" aria-label={gettext("close")}>
          ×
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:info} flash={@flash} />
    <.flash kind={:error} flash={@flash} />
    <.flash
      kind={:error}
      id="disconnected"
      phx-disconnected={show("#disconnected")}
      phx-connected={hide("#disconnected")}
      hidden
    >
      {gettext("We can't find the Internet, attempting to reconnect…")}
    </.flash>
    """
  end

  # JS Commands

  def show(js \\ %JS{}, selector),
    do: JS.show(js, to: selector, transition: {"", "", ""})

  def hide(js \\ %JS{}, selector),
    do: JS.hide(js, to: selector, time: 200, transition: {"", "", ""})
end
