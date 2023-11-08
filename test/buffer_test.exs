defmodule BufferTest do
  @moduledoc false
  use ExUnit.Case

  alias Buffer.Queue

  setup do
    start_supervised!({Queue, name: :my_queue, size: 10})
    [name: :my_queue]
  end

  describe "put/3" do
    test "adds items to the buffer queue" do
      assert Queue.put(:my_queue, [1, 2, 3]) == :ok
    end

    test "returns :error if the buffer queue is full" do
      assert Queue.put(:my_queue, Enum.to_list(1..10)) == :ok
      assert Queue.put(:my_queue, [11]) == {:error, :full}
    end
  end

  describe "take/2" do
    test "removes and returns items from the buffer queue" do
      assert Queue.put(:my_queue, [1, 2, 3]) == :ok
      assert Queue.take(:my_queue) == [1, 2, 3]
      assert Queue.take(:my_queue) == []
    end
  end

  describe "size/2" do
    test "returns the size of the buffer queue" do
      assert Queue.put(:my_queue, [1, 2, 3]) == :ok
      assert Queue.size(:my_queue) == 3
    end
  end
end
