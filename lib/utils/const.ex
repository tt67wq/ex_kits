defmodule ExKits.Utils.Const do
  @moduledoc """
  This module is similar to ets in that it provides a storage for Erlang terms that can be accessed in constant time,
  but with the difference that persistent_term has been highly optimized for reading terms at the expense of writing and updating terms.

  When a persistent term is updated or deleted, a global garbage collection pass is run to scan all processes for the deleted term,
  and to copy it into each process that still uses it.

  Therefore, persistent_term is suitable for storing Erlang terms that are frequently accessed but never or infrequently updated.
  """

  @doc """
  put a key-value pair into the persistent term storage
  NOTE: very very expensive, use with caution

  ## Examples

      iex> ExKits.Utils.Const.put(:key, :val)
  """
  @spec put(term(), term()) :: :ok
  def put(key, val) do
    :persistent_term.put(key, val)
  end

  @spec get(term()) :: term() | nil
  def get(key) do
    :persistent_term.get(key)
  end
end
