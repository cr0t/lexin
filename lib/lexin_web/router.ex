defmodule LexinWeb.Router do
  use LexinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LexinWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LexinWeb do
    pipe_through :browser

    live "/", DictionaryLive, :homepage
    live "/dictionary/", DictionaryLive
    live "/dictionary/:query", DictionaryLive, :definition

    get "/sw.js", ServiceWorkerController, :index

    # Static pages (About, Help, etc.)
    get "/about", PagesController, :about
    get "/cookies", PagesController, :cookies
    get "/install", PagesController, :install

    scope "/share" do
      get "/og/:lang/:query", OGImageController, :image
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LexinWeb do
  #   pipe_through :api
  # end

  if Application.compile_env(:exxy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LexinWeb.Telemetry
    end
  end
end
