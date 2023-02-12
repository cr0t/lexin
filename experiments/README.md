# Experiments

We use this directory as a "playground" – the place for non-final code, for (white) hacking, when
we are playing with data, or validating some idea.

It's good if can document our playground sessions and that's why we leverage the full-power of
[Livebook](https://livebook.dev/) technology: which are basically Markdown files, but with code
snippets that we can run instantly to see the results.

## How to Play

### Install Livebook

You need to install Livebook on your machine (or use Docker, for example), see documentations on
their website.

If you're on the macOS and use [asdf](https://asdf-vm.com/), you need to do this:

```console
$ mix escript.install hex livebook
$ asdf elixir reshim
```

### Run Livebook

Now we can simply run the server (preferably from the root directory of this repository or from
the `experiments/`):

```console
$ livebook server
```

You should be prompted to open a browser window with the given address in the console. From this,
we can follow instructions in Livebook UI.

The gist of them: find the `experiments` directory and open any of `.livemd` files in it.

### Writing New Experiments

Check a few existing examples in this directory to get the idea of how we do that.

And, please, make sure that you're writing not just code in these files, but with a lots of your
thoughts, notes and comments on what and why you're doing this.
