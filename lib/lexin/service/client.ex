defmodule Lexin.Service.Client do
  @moduledoc """
  Provides facility to send requests to Lexin API.

  Note on the `Status` field in the response: there is no available documentation for Lexin API,
  but this is what we have found so far. `Status` field values in the response we've seen:

  - `found` – the keyword exists; the lookup result is given as "Result"
  - `corrected` – misspelling with a unique correction; the correction is given as "Corrections"
    and lookup results are given as "Results"
  - `no unique matching` – misspelling with several possible corrections; a list of suggested
    corrections is given as "Corrections"
  - `no matching` – no word matches the keyword

  For now, we do not care about anything, except "found".

  TODO: we do not support Swedish to Swedish (yet), because Lexin API returns non-standard (for
  translation) data structure; this is what we need to take a look in future
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://lexin.nada.kth.se/lexin"
  plug Tesla.Middleware.JSON

  @supported_languages %{
    "albanian" => :alb,
    "arabic" => :ara,
    "bosnian" => :bos,
    "finnish" => :fin,
    "greek" => :gre,
    "croatian" => :hrv,
    "northern_kurdish" => :kmr,
    "persian" => :per,
    "russian" => :rus,
    "serbian" => :srp,
    "somali" => :som,
    "southern_kurdish" => :sdh,
    # "swedish" => :swe,
    "turkish" => :tur
  }

  @spec definitions(word :: String.t(), lang :: String.t()) :: {:ok, [map()]} | {:error, atom()}
  def definitions(word, lang) do
    with {:ok, params} <- get_params(word, lang),
         {:ok, response} <- get("/service", query: params),
         {:ok, definitions} <- parse(response) do
      {:ok, definitions}
    else
      err -> err
    end
  end

  defp get_params(word, lang) do
    lang_code = @supported_languages[lang]

    if lang_code do
      search = "both,swe_#{lang_code},#{word}"
      params = [searchinfo: search, output: "JSON"]

      {:ok, params}
    else
      {:error, :language_not_supported}
    end
  end

  defp parse(%{status: 200, body: %{"Status" => "found", "Result" => definitions}}),
    do: {:ok, definitions}

  defp parse(%{status: 200}),
    do: {:error, :not_found}

  defp parse(_),
    do: {:error, :no_response}
end
