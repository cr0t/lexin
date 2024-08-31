defmodule Lexin.Dictionary.SupervisorTest do
  use ExUnit.Case, async: true
  doctest Lexin.Dictionary.Supervisor

  test "bootstraps a Registry and Repo-related processes" do
    assert Process.whereis(Lexin.Dictionary.Registry) != nil

    # there should be workers for the available dictionary files (2 in test env)
    assert Registry.count(Lexin.Dictionary.Registry) == 2
  end
end
