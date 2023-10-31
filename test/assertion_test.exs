defmodule AssertionTest do
  @moduledoc false
  use ExUnit.Case

  import ExKits.Macros.Assertion

  test "performing a boolean assertion" do
    assert do_assert(fn -> 1 + 1 == 2 end, "1 + 1 should equal 2") == :ok

    assert do_assert(fn -> 1 + 1 == 3 end, "1 + 1 should equal 2") ==
             {:error, "1 + 1 should equal 2"}
  end

  test "performing an assertion that checks if an object exists" do
    assert assert_exists(42, "Object should exist") == :ok

    assert assert_exists(nil, "Object should exist") ==
             {:error, "Object should exist"}
  end

  test "performing an assertion that checks if an object does not exist" do
    assert assert_non_exists(nil, "Object should not exist") == :ok

    assert assert_non_exists(42, "Object should not exist") ==
             {:error, "Object should not exist"}
  end
end
