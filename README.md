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
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

### Docker & Docker Compose

Alternatively, you can use Docker and have nothing but editor on your host machine to work with the project.

**For the first time** (or if you want to install/update deps), you need to run `mix deps.get` command inside the `phoenix` service container: `docker-compose run --rm phoenix mix deps.get`.

Now, we can run `docker-compose up` (to run interactively) or `docker-compose --detach` (to run in background).

Check [`docker-compose.yml`](docker-compose.yml) file for details.

## Testing

Simple way: `mix test`. _To run all the tests._

Advanced way: `fswatch lib test | mix test --listen-on-stdin`. _If you want to autorun tests every time you save the files in `lib` or `test` directories – useful when focusing on writing tests._

## Convert XML to SQLite

To get faster lookups for words in the available vocabularies, we need to convert language dictionaries from XML to SQLite.

We have prepared a simple script and converter module that takes input XML filename and output SQLite filename, parses XML and then inserts data in the simple SQL (only two tables) structure file.

This helps us to lookup words only in 10-15ms (for the set of ~100k words to search in).

Here is the way to prepare these `.sqlite` files which can be consumed later by the Lexin application:

```console
mix run scripts/converter.exs --input swe_rus.xml --output swe_rus.sqlite
```

See more in the module docs to [`lib/lexin/xml_converter.ex`](lib/lexin/xml_converter.ex).
