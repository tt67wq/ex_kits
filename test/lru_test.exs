defmodule LRUTest do
  @moduledoc false
  use ExUnit.Case

  alias ExKits.Cache.LRU

  setup do
    # create a new LRU cache with a size of 3
    {:ok, _pid} = LRU.start_link(:lru, 3)
    {:ok, lru: :lru}
  end

  test "put adds a key-value pair to the cache" do
    :ok = LRU.put(:lru, :a, 1)
    assert LRU.get(:lru, :a) == 1
  end

  test "put updates the value of an existing key" do
    :ok = LRU.put(:lru, :a, 1)
    assert LRU.get(:lru, :a) == 1

    :ok = LRU.put(:lru, :a, 2)
    assert LRU.get(:lru, :a) == 2
  end

  test "update updates the value of an existing key" do
    :ok = LRU.put(:lru, :a, 1)
    assert LRU.get(:lru, :a) == 1

    :ok = LRU.update(:lru, :a, 2)
    assert LRU.get(:lru, :a) == 2
  end

  test "update does nothing if the key does not exist" do
    assert LRU.get(:lru, :a) == nil

    :ok = LRU.update(:lru, :a, 2)
    assert LRU.get(:lru, :a) == nil
  end

  test "oversize auto deletes the least recently used key" do
    :ok = LRU.put(:lru, :a, 1)
    :ok = LRU.put(:lru, :b, 2)
    :ok = LRU.put(:lru, :c, 3)
    assert LRU.get(:lru, :a) == 1
    assert LRU.get(:lru, :b) == 2
    assert LRU.get(:lru, :c) == 3

    :ok = LRU.put(:lru, :d, 4)
    assert LRU.get(:lru, :a) == nil
    assert LRU.get(:lru, :b) == 2
    assert LRU.get(:lru, :c) == 3
    assert LRU.get(:lru, :d) == 4
  end

  test "select returns the first value that matches the condition" do
    :ok = LRU.put(:lru, :a, 1)
    :ok = LRU.put(:lru, :b, 2)
    :ok = LRU.put(:lru, :c, 3)
    assert LRU.select(:lru, fn value -> value > 1 end) == 2
  end
end
