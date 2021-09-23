defmodule Lexin.Service.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://lexin.nada.kth.se/lexin"
  plug Tesla.Middleware.JSON

  @spec definitions(word :: String.t()) :: [map()]
  def definitions(word) do
    params = [searchinfo: "to,swe_rus,#{word}", output: "JSON"]

    {:ok, %{body: response}} = get("/service", query: params)

    %{"Result" => raw_definitions} = response

    raw_definitions
  end
end
