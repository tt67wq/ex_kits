defmodule ExKits.Macros.Assertion do
  @moduledoc """
  This module provides macros for performing assertions in Elixir code.

  ## Examples

  ```Elixir
  import ExKits.Macros.Assertion

  # Perform a boolean assertion:
  do_assert(fn -> 1 + 1 == 2 end, "1 + 1 should equal 2")

  # Perform an assertion that checks if an object exists:
  assert_exists(obj, "Object should exist")

  # Perform an assertion that checks if an object does not exist:
  assert_non_exists(obj, "Object should not exist")
  ```
  """
  defmacro do_assert(assert_fn, error_msg) do
    quote do
      if unquote(assert_fn).() do
        :ok
      else
        {:error, unquote(error_msg)}
      end
    end
  end

  defmacro assert_exists(obj, error_msg) do
    quote do
      if (fn -> not is_nil(unquote(obj)) end).() do
        :ok
      else
        {:error, unquote(error_msg)}
      end
    end
  end

  defmacro assert_non_exists(obj, error_msg) do
    quote do
      if (fn -> is_nil(unquote(obj)) end).() do
        :ok
      else
        {:error, unquote(error_msg)}
      end
    end
  end
end
