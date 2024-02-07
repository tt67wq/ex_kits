defmodule ExKits.Cache.Storage do
  @moduledoc """
  A cache storage module that provides a simple interface for storing and retrieving key-value pairs.

  ## Examples

      iex> storage = ExKits.Cache.Storage.new([])
      iex> ExKits.Cache.Storage.put(storage, :key, "value", [])
      :ok
      iex> ExKits.Cache.Storage.get(storage, :key)
      "value"
  """

  # types

  @type t :: atom()
  @type opts :: Keyword.t()
  @type k :: term()
  @type v :: term() | nil
  @type put_opts :: [
          {:ttl, pos_integer() | :infinity}
        ]

  @callback get(k) :: v
  @callback put(k, v, put_opts()) :: :ok
  @callback del(k) :: any()

  defmacro __using__(_) do
    quote do
      @behaviour ExKits.Cache.Storage

      def get(k), do: raise("Not implemented")
      def put(k, v, opts), do: raise("Not implemented")
      def del(k), do: raise("Not implemented")

      defoverridable(get: 1, put: 3, del: 1)
    end
  end

  @doc """
  get the value of a key from the cache storage

  ## Examples

      iex> storage = ExKits.Storage.ETS.new([])
      iex> ExKits.Cache.Storage.get(storage, :key)
      nil
  """
  @spec get(t, k) :: v
  def get(storage, k), do: delegate(storage, :get, [k])

  @doc """
  put a key-value pair into the cache storage

  ## Examples

      iex> storage = ExKits.Storage.ETS.new([])
      iex> ExKits.Cache.Storage.put(storage, :key, "value", [])
      :ok
  """
  @spec put(t, k, v, put_opts()) :: :ok
  def put(storage, k, v, opts), do: delegate(storage, :put, [k, v, opts])

  @doc """
  delete a key-value pair from the cache storage

  ## Examples

      iex> storage = ExKits.Storage.ETS.new([])
      iex> ExKits.Cache.Storage.del(storage, :key)
      :ok
  """
  @spec del(t, k) :: any()
  def del(storage, k), do: delegate(storage, :del, [k])

  defp delegate(impl, func, args), do: apply(impl, func, args)
end

defmodule ExKits.Storage.ETS do
  @moduledoc """
  ExKits.Cache.Storage implementation by ETS
  """

  use ExKits.Cache.Storage
  use GenServer

  @impl ExKits.Cache.Storage
  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  @impl ExKits.Cache.Storage
  def put(key, value, opts), do: GenServer.cast(__MODULE__, {:put, key, value, opts})

  @impl ExKits.Cache.Storage
  def del(key), do: GenServer.cast(__MODULE__, {:del, key})

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    name = Keyword.get(opts, :name, :ets_cache)
    interval = Keyword.get(opts, :interval, 60_000)
    :ets.new(name, [:named_table, :public, :set])
    Process.send_after(self(), :cleanup, interval)
    {:ok, %{name: name, interval: interval}}
  end

  @impl true
  def handle_info(:cleanup, %{name: name, interval: interval} = state) do
    now = :os.system_time(:millisecond)

    :ets.select_delete(
      name,
      [
        {{:"$1", :"$2", :infinity}, [], [false]},
        {{:"$1", :"$2", :"$3"}, [{:<, :"$3", now}], [true]},
        {:_, [], [false]}
      ]
    )

    Process.send_after(self(), :cleanup, interval)
    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, _from, %{name: name} = state) do
    value =
      case :ets.lookup(name, key) do
        [{^key, value, :infinity}] ->
          value

        [{^key, value, timeout}] when is_integer(timeout) ->
          if timeout < :os.system_time(:millisecond) do
            :ets.delete(name, key)
            nil
          else
            value
          end

        _ ->
          nil
      end

    {:reply, value, state}
  end

  @impl true
  def handle_cast({:put, key, value, opts}, %{name: name} = state) do
    case Keyword.get(opts, :ttl, :infinity) do
      :infinity ->
        :ets.insert(name, {key, value, :infinity})

      ttl when is_integer(ttl) ->
        :ets.insert(name, {key, value, System.system_time(:millisecond) + ttl})
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast({:del, key}, %{name: name} = state) do
    :ets.delete(name, key)
    {:noreply, state}
  end
end
