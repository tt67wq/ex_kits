defmodule ExKitsTest do
  use ExUnit.Case
  doctest ExKits

  test "greets the world" do
    assert ExKits.hello() == :world
  end
end
