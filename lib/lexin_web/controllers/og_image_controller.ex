defmodule LexinWeb.OGImageController do
  use LexinWeb, :controller

  import Lexin.Dictionary.Helpers

  alias Lexin.Dictionary

  @template_filepath "lib/lexin_web/components/og_image.svg.eex"
  @external_resource @template_filepath
  @template_svg EEx.compile_file(@template_filepath)

  def image(conn, %{"lang" => lang, "query" => query}) do
    with true <- lang in Dictionary.languages(),
         {:ok, definitions} <- Dictionary.definitions(lang, query) do
      og_image =
        definitions
        |> hd()
        |> generate_svg(lang)
        |> generate_png()

      conn
      |> put_resp_content_type("image/png")
      |> send_resp(200, og_image)
    else
      _ ->
        raise LexinWeb.DefinitionNotFoundError
    end
  end

  defp generate_svg(definition, lang) do
    # TODO: use gettext for langs
    assigns = [
      base_lang: "Svenska",
      target_lang: String.capitalize(lang),
      definition: definition.value,
      transcription: definition.base.phonetic.transcription,
      inflections: Enum.join(inflections(definition), ", "),
      meaning: definition.base.meaning,
      target_translation: definition.target.translation,
      target_synonyms: Enum.join(definition.target.synonyms, ", ")
    ]

    {svg, _bindings} = Code.eval_quoted(@template_svg, assigns)

    svg
  end

  defp generate_png(svg) do
    {image, _flags} = Vix.Vips.Operation.svgload_buffer!(svg)

    Image.write!(image, :memory, suffix: ".png")
  end
end
