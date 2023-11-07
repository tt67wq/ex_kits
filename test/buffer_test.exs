defmodule BufferTest do
  @moduledoc false
  use ExUnit.Case

  alias Buffer.Queue

  describe "start_link/3" do
    test "starts a new buffer queue with the given name and capacity" do
      {:ok, pid} = Queue.start_link(:my_queue, 10)
      assert pid != nil
      assert :ets.info(:my_queue_buff)[:owner] == pid
    end
  end

  describe "put/3" do
    test "adds items to the buffer queue" do
      {:ok, _pid} = Queue.start_link(:my_queue, 10)
      assert Queue.put(:my_queue, [1, 2, 3]) == :ok
    end

    test "returns :error if the buffer queue is full" do
      {:ok, _pid} = Queue.start_link(:my_queue, 2)
      assert Queue.put(:my_queue, [1, 2]) == :ok
      assert Queue.put(:my_queue, [3]) == {:error, :full}
    end
  end

  describe "take/2" do
    test "removes and returns items from the buffer queue" do
      {:ok, _pid} = Queue.start_link(:my_queue, 10)
      assert Queue.put(:my_queue, [1, 2, 3]) == :ok
      assert Queue.take(:my_queue) == [1, 2, 3]
      assert Queue.take(:my_queue) == []
    end
  end

  describe "size/2" do
    test "returns the size of the buffer queue" do
      {:ok, _pid} = Queue.start_link(:my_queue, 10)
      assert Queue.put(:my_queue, [1, 2, 3]) == :ok
      assert Queue.size(:my_queue) == 3
    end
  end
end
