ExUnit.start(exclude: [:wallaby])

# `mix test` - fast suite only, no Wallaby, no chromedriver needed
# `WALLABY=1 mix test --include wallaby` - everything, including the browser test
if System.get_env("WALLABY"), do: {:ok, _} = Application.ensure_all_started(:wallaby)
