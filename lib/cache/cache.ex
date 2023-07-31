defmodule ExKits.Cache do
  @moduledoc """
  simple cache framework
  """

  alias ExKits.Cache.Storage

  @type storage :: Storage.t()
  @type k :: term()
  @type v :: term() | nil
  @type put_opts :: [
          {:ttl, pos_integer() | :infinity}
        ]
  @type fallback :: (k() -> {:commit, v()} | {:ignore, v()})

  @spec fetch(storage, k, put_opts(), fallback) :: v
  def fetch(storage, key, opts, fallback) do
    with nil <- Storage.get(storage, key) do
      case fallback.(key) do
        {:commit, value} ->
          Storage.put(storage, key, value, opts)
          value

        {:ignore, value} ->
          value
      end
    end
  end

  @spec evict(storage, k) :: any()
  def evict(storage, key), do: Storage.del(storage, key)
end
