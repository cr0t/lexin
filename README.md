# Lexin Light

It's a small web application for Swedish dictionary service Lexin.

Lexin Light provides a new modern and responsive user interface to the [Lexin](http://lexin2.nada.kth.se/lexin/) dictionary service. You can find some [history notes](docs/HISTORY.md) about creation and first look of this application.

## Development

Clone the repository to your development machine. To run the app, we have two approaches: native and Docker.

Whichever approach you chose, you can visit [`localhost:4000`](http://localhost:4000) from your browser, when you've successfully executed the Phoenix server locally. See the details below.

### Native

#### Pre-requisites

You need to have Elixir installed and available in your environment.

Preferred way is to install [asdf](https://asdf-vm.com/) utility: then it will be possible to use the same version of Elixir/Erlang/NodeJS which are defined in the `.tool-versions` file in the repository root.

#### Run a Phoenix Server

To start your local development server:

* Install dependencies with `mix deps.get`
* Convert or use demo dictionary file (see the section below in this README)
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

### Docker & Docker Compose

Alternatively, you can use Docker and have nothing but editor on your host machine to work with the project.

> **For the first time** (or if you want to install/update deps), you need to run `mix deps.get` command inside the `phoenix` service container: `docker-compose run --rm phoenix mix deps.get`.

Now, we can run `docker-compose up` (to run interactively) or `docker-compose --detach` (to run in background).

Check [`docker-compose.yml`](docker-compose.yml) file for details.

## Testing

Simple way: `mix test`. _(To run all the tests)_

Advanced way: `fswatch lib test | mix test --listen-on-stdin`.

> If you want to autorun tests every time you save the files in `lib` or `test` directories – useful when focusing on writing tests.

## Convert XML to SQLite

To make this app work properly, we need to provide it a directory with `.sqlite` dictionary files which contain definitions data.

> To run this app locally, you must create `dictionaries` directory in the app root, and copy `test/fixtures/dictionaries/russian.sqlite` into this folder; though it's extremely limited and contains only 5 word definitions.
>
> You can request access to the original XML files from authors of the original Lexin service (check [https://lexin.nada.kth.se/lexin/](https://lexin.nada.kth.se/lexin/) for the contact information). These files are stored in the SVN repository and we do not want to copy them here and store in this repo, as they might become out of sync.

You can convert all of them, or just a few selected ones.

> **It is important** to name output files according to the list of supported languages options (see [`lib/lexin_web/live/components/search_form_component.ex`](lib/lexin_web/live/components/search_form_component.ex#L32-L52) for details). Our application filters shown list of languages according to available dictionaries it finds in the corresponding directory.

You might have similar conversion sequence of commands:

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

`scripts/converter.exs` uses `XMLConverter`, see more in the corresponding module – [`lib/lexin/dictionary/xml_converter.ex`](lib/lexin/dictionary/xml_converter.ex).
