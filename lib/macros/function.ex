defmodule ExKits.Macros.FunctionGenerator do
  @moduledoc """
  This module provides a macro for generating functions in Elixir code.
  ```elixir
  require FunctionGenerator

  FunctionGenerator.generate_function :add, [a, b], do: a + b
  ```
  """
  defmacro generate_function(name, args, code) do
    quote do
      def unquote(name)(unquote_splicing(args)) do
        unquote(code)
      end
    end
  end
end
