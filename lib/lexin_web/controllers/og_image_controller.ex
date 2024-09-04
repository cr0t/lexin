defmodule LexinWeb.OGImageController do
  use LexinWeb, :controller

  import Lexin.Dictionary.Helpers

  alias Lexin.Dictionary

  @template_filepath "lib/lexin_web/seo/og_image.svg.eex"
  @external_resource @template_filepath
  @template_svg EEx.compile_file(@template_filepath)

  # directory where we will put generated PNGs
  @cache_path Application.compile_env!(:lexin, :og_cache_path)

  def image(conn, %{"lang" => lang, "query" => query}) do
    # TODO: add a monitoring to the cache directory and clean it when it starts to take too much space
    lang_cache_path = Path.join([Application.app_dir(:lexin), @cache_path, lang])
    image_cache_path = Path.join([lang_cache_path, "#{query}.png"])

    og_image =
      if File.exists?(image_cache_path) do
        File.read!(image_cache_path)
      else
        generate_and_cache(lang, query, lang_cache_path, image_cache_path)
      end

    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, og_image)
  end

  defp generate_and_cache(lang, query, lang_cache_path, image_cache_path) do
    with true <- lang in Dictionary.languages(),
         {:ok, definitions} <- Dictionary.definitions(lang, query) do
      definitions
      |> hd()
      |> generate_svg(lang)
      |> generate_png()
      |> then(fn image ->
        try do
          # ensure that language cache directory exists, and write the file
          File.mkdir_p!(lang_cache_path)
          File.write!(image_cache_path, image)

          image
        rescue
          _ -> image
        end
      end)
    else
      _ -> raise LexinWeb.DefinitionNotFoundError, message: "Word not found"
    end
  end

  defp generate_svg(definition, lang) do
    # TODO: use gettext for langs
    assigns = [
      base_lang: "Svenska",
      target_lang: String.capitalize(lang),
      definition: get_in(definition.value) || "",
      transcription: get_in(definition.base.phonetic.transcription) || "",
      inflections: Enum.join(inflections(definition), ", "),
      meaning: get_in(definition.base.meaning) || "",
      target_translation: get_in(definition.target.translation) || "",
      target_synonyms: Enum.join(get_in(definition.target.synonyms) || [], ", ")
    ]

    {svg, _bindings} = Code.eval_quoted(@template_svg, assigns)

    svg
  end

  defp generate_png(svg) do
    {image, _flags} = Vix.Vips.Operation.svgload_buffer!(svg)

    Image.write!(image, :memory, suffix: ".png")
  end
end
