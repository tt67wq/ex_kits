defmodule ExKits.Macros.Go do
  @moduledoc false

  defmacro go(supervisor, task) do
    quote do
      Task.Supervisor.start_child(unquote(supervisor), fn -> unquote(task) end)
    end
  end
end
