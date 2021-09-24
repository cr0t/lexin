defmodule Lexin.Service.Client do
  @moduledoc """
  Provides facility to send requests to Lexin API.

  Note on the `Status` field in the response: there is no available documentation for Lexin API,
  but this is what we have found so far. `Status` field values in the response we've seen:

  - "found"
  - "corrected"
  - "no unique maching"
  - "no matching"

  We do not take into account anything, but "found".
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://lexin.nada.kth.se/lexin"
  plug Tesla.Middleware.JSON

  @spec definitions(word :: String.t()) :: {:ok, [map()]} | {:error, atom()}
  def definitions(word) do
    params = [searchinfo: "to,swe_rus,#{word}", output: "JSON"]

    with {:ok, response} <- get("/service", query: params),
         {:ok, definitions} <- parse(response) do
      {:ok, definitions}
    else
      err -> err
    end
  end

  defp parse(%{status: 200, body: %{"Status" => "found", "Result" => definitions}}),
    do: {:ok, definitions}

  defp parse(%{status: 200}),
    do: {:error, :not_found}

  defp parse(_),
    do: {:error, :no_response}
end
