defmodule ExKits.Macros.Constants do
  @moduledoc """
  defmodule MyApp.Constant do
  import Constants

    const :facebook_url, "http://facebook.com/rohanpujaris"
  end

  MyApp.Constant.facebook_url  # You can use this line anywhere to get the facebook url.
  """
  defmacro const(const_name, const_value) do
    quote do
      def unquote(const_name)(), do: unquote(const_value)
    end
  end
end
