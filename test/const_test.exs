defmodule MyConst do
  @moduledoc false
  import ExKits.Macros.Constants

  const(:pi, 3.14159)
end

defmodule ConstantsTest do
  @moduledoc false
  use ExUnit.Case

  test "defining and using a constant" do
    require MyConst
    assert MyConst.pi() == 3.14159
  end
end
