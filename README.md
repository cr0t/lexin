# Lexin Mobi

It's a small web and mobile application for the Swedish dictionary.

## Intro

Lexin Mobi provides a new, modern, and responsive user interface to the [Lexin](http://lexin2.nada.kth.se/lexin/) dictionary service. You can find some [historical notes](docs/HISTORY.md) about the creation and first visuals of this application.

Lexin Mobi is written as [a Progressive Web App (PWA)](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps) and can be installed and used on mobile devices or on desktops.

### Screenshots

<table>
  <tr>
    <td><img width="612" alt="image" src="https://user-images.githubusercontent.com/113878/196228786-299064e9-909a-4dac-9af3-6aebc148ef13.png"></td>
    <td><img width="612" alt="image" src="https://user-images.githubusercontent.com/113878/196228913-e5491fb7-7992-4075-bccd-a9ea58d33254.png"></td>
  </tr>
</table>

## Development

Clone the repository on your development machine. To run the app, we have two approaches: native and Docker.

Whichever approach you choose, you can visit [`localhost:4000`](http://localhost:4000) from your browser, when you've successfully run the Phoenix server locally. See the details below.

### Native

#### Pre-requisites

You need to have Elixir installed and available in your environment.

The preferred way is to install the [asdf](https://asdf-vm.com/) utility: then it will be possible to use the same version of Elixir/Erlang/Node.js, which is defined in the `.tool-versions` file in the repository root.

#### Run a Phoenix Server

To start your local development server:

1. Install dependencies with `mix deps.get`.
2. Convert or use a demo dictionary file (see the section below in this README).
3. Start Phoenix endpoint with `mix phx.server` or `iex -S mix phx.server`.

### Docker & Docker Compose

Alternatively, you can use Docker and have nothing but an editor on your host machine to work with the project.

> **For the first time** (or if you want to install/update dependencies), you need to run `mix deps.get` command inside the `phoenix` service container: `docker-compose run --rm phoenix mix deps.get`.

Now, we can run `docker-compose up` (to run interactively) or `docker-compose --detach` (to run in the background).

Check the [`docker-compose.yml`](docker-compose.yml) file for details.

### Testing

Straightforward way: `mix test`. _(To run all the tests)_

Advanced way: `fswatch lib test | mix test --listen-on-stdin`.

> If you want to run tests automatically every time you save the files in `lib` or `test` directories – useful when focusing on writing tests.

#### Integration Testing

We use [Wallaby](https://hexdocs.pm/wallaby) and [ChromeDriver](https://sites.google.com/chromium.org/driver/) to run integration tests. Read example code in our `tests/integration` directory or on Wallaby's documentation page.

### Releasing

When you're done with the development and the tests are green, we can run the release script. It compiles the app inside a Docker container, cleans it, prepares the runner image, and uploads it to the GitHub Container Registry.

> [!warning] Before Release Checklist
>
> - check or bump the app version in the `mix.exs`
> - ensure that `.env` and `.tool-versions` files are in harmony
> - run and check `mix test` for the last time

To execute a release, we can run this from the project's root directory:

```console
./scripts/release.sh
```

> [!tip] GitHub Container Registry Login
>
> If you see _"unauthorized: unauthenticated: User cannot be authenticated with the token provided"_ error at the attempt to push the new image into the container repository, you might need to run this:
>
> ```console
> docker login --username cr0t ghcr.io
> # use `--password <ghcr_token>` option to avoid interactive prompt for the token
> ```
>
> _You can generate a token at https://github.com/settings/tokens._

To run the container, we must mount two directories (and configure corresponding environment variables): for dictionaries and for sitemaps, as these files are outside the release image. Check [`docker-compose.prod.yml`](docker-compose.prod.yml) as an example.

## Dictionary Files

To make this app work properly, we need to provide it with a directory with `.sqlite` dictionary files, which contain definitions data.

> To run this app locally, you must create `priv/dictionaries` directory, then copy files from `test/fixtures/dictionaries/` there (fixtures are extremely limited, and contain only ~7 words definitions).
>
> You can request access to the original XML files from authors of the original Lexin service (check [https://lexin.nada.kth.se/lexin/](https://lexin.nada.kth.se/lexin/) for the contact information). These files stored in the SVN repository, and we do not want to copy them here and store in this GitHub repository, as they might become out of sync.

You can convert all of them, or just a few selected ones.

> **It is important** to name output files according to the list of supported languages options (see [`lib/lexin_web/live/components/search_form_component.ex`](lib/lexin_web/live/components/search_form_component.ex)). Our application filters shown list of languages according to available dictionaries it finds in the corresponding directory.

You might have a similar conversion sequence of commands:

```console
$ mix run scripts/converter.exs --input dictionaries/swe_ara.xml --output dictionaries/arabic.sqlite
Resetting database...
Parsing input XML...
Inserting into SQLite...
22014 / 22014
Done!
$ mix run scripts/converter.exs --input dictionaries/swe_azj.xml --output dictionaries/azerbaijani.sqlite
Resetting database...
Parsing input XML...
Inserting into SQLite...
5539 / 5539
Done!
$ mix run scripts/converter.exs --input dictionaries/swe_eng.xml --output dictionaries/english.sqlite
Resetting database...
Parsing input XML...
Inserting into SQLite...
22013 / 22013
Done!
```

`scripts/converter.exs` uses `XMLConverter`, see more in the corresponding [module](lib/lexin/dictionary/xml_converter.ex).
