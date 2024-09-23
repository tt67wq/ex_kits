defmodule ExKits.Macros.Constants do
  @moduledoc """
  This module provides a macro for defining compile-time constants in Elixir code.

  ## Examples

  ```Elixir

  # Define a constant:
  defmodule MyConst do
    import ExKits.Macros.Constants

    @dict %{a: 1, b: 2}

    const :pi, 3.14159
    const :dict, Macro.escape(@dict)
  end

  # Use a constant:

  require MyConst
  @pi MyConst.pi()

  IO.puts(@pi)
  ```
  """
  defmacro const(const_name, const_value) do
    quote do
      defmacro unquote(const_name)(), do: unquote(const_value)
    end
  end
end
