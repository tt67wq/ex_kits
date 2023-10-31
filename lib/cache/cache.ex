defmodule ExKits.Cache do
  @moduledoc """
  This module provides a simple cache framework for storing and retrieving key-value pairs.

  ## Examples

  Retrieve a value from the cache:

      ```elixir
      storage = SomeImplement.new()
      ExKits.Cache.fetch(storage, :key, [{:ttl, 3000}], fn _key ->
        {:commit, "value"}
      end)
      |> IO.puts()
      ```

  Evict a value from the cache:

      ```elixir
      storage = SomeImplement.new()
      ExKits.Cache.evict(storage, :key)
      ```

  ## Security Warning

  This module provides a basic implementation of a cache framework
  and should not be used in production environments without proper security review and testing.
  """

  alias ExKits.Cache.Storage

  @type storage :: Storage.t()
  @type k :: term()
  @type v :: term() | nil
  @type put_opts :: [
          {:ttl, pos_integer() | :infinity}
        ]
  @type fallback :: (k() -> {:commit, v()} | {:ignore, v()})

  @doc """
  This function retrieves a value from the cache storage with the given key.
  If the value is not found, the fallback function is called to generate a new value,
  which is then stored in the cache storage and returned. If the value is found, it is returned directly.

  The storage argument is a cache storage, which is an opaque data structure that holds the cached key-value pairs.
  The key argument is the key of the value to retrieve.

  The opts argument is a list of put options, which can be used to set a time-to-live (TTL) for the cached value.

  The fallback argument is a function that takes the cache key as an argument
  and returns either a {:commit, value} tuple to indicate that the value should be stored in the cache,
  or a {:ignore, value} tuple to indicate that the value should not be stored in the cache.

  The function returns the cached value, or nil if the value is not found
  and the fallback function returns a {:ignore, value} tuple.
  If the fallback function returns a {:commit, value} tuple, the value is stored in the cache storage and returned.

  ## Examples

      iex> storage = SomeImplement.new()
      iex> ExKits.Cache.fetch(storage, :key, [{:ttl, 3000}], fn _key ->
        {:commit, "value"}
      end)
      |> IO.puts()
  """
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

  @doc """
  This function removes the cached value with the given key from the cache storage.

  The storage argument is a cache storage, which is an opaque data structure that holds the cached key-value pairs.
  The key argument is the key of the value to remove from the cache.

  ## Examples

      ```Elixir
      storage = SomeImplement.new()
      ExKits.Cache.fetch(storage, :key, [], fn _key ->
      {:commit, "value"}
      end)
      |> IO.puts()

      ExKits.Cache.evict(storage, :key)
      ```
  """
  @spec evict(storage, k) :: any()
  def evict(storage, key), do: Storage.del(storage, key)
end
