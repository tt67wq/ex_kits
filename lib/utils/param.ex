defprotocol ExKits.Utils.Param do
  @spec to_integer(t) :: integer()
  def to_integer(param)

  @spec to_map(t) :: map()
  def to_map(param)

  @spec to_string(t) :: String.t()
  def to_string(param)
end

defimpl ExKits.Utils.Param, for: BitString do
  def to_integer(param), do: String.to_integer(param)
  def to_map(param), do: Jason.decode!(param)
  def to_string(param), do: param
end

defimpl ExKits.Utils.Param, for: Integer do
  def to_integer(param), do: param
  def to_map(_), do: %{}
  def to_string(param), do: "#{param}"
end

defimpl ExKits.Utils.Param, for: Map do
  def to_integer(_), do: 0
  def to_map(param), do: param
  def to_string(param), do: Jason.encode!(param)
end
