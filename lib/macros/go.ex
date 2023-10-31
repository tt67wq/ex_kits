defmodule ExKits.Macros.Go do
  @moduledoc """
  This module provides a macro for starting a new task under a given supervisor.

  ## Examples

  Start a new task under a supervisor:

      supervisor = MySupervisor.Supervisor
      ExKits.Macros.go(supervisor, IO.puts("Hello, world!"))
  """

  defmacro go(supervisor, task) do
    quote do
      Task.Supervisor.start_child(unquote(supervisor), fn -> unquote(task) end)
    end
  end
end
