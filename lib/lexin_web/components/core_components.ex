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
            <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
            <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
            {@title}
          </div>
          <div class="my-1 text-base">
            {msg}
          </div>
        </div>

        <button type="button" class="group flex self-center" aria-label={gettext("close")}>
          <.icon name="hero-x-mark-solid" class="opacity-40 group-hover:opacity-70" />
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

  @doc """
  Renders a [Hero Icon](https://heroicons.com).

  Hero icons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid an mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from your `assets/vendor/heroicons` directory and bundled
  within your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  # JS Commands

  def show(js \\ %JS{}, selector),
    do: JS.show(js, to: selector, transition: {"", "", ""})

  def hide(js \\ %JS{}, selector),
    do: JS.hide(js, to: selector, time: 200, transition: {"", "", ""})
end
