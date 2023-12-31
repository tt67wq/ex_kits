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

  @type t :: struct()
  @type opts :: Keyword.t()
  @type k :: term()
  @type v :: term() | nil
  @type put_opts :: [
          {:ttl, pos_integer() | :infinity}
        ]

  @callback new(opts) :: t
  @callback get(t, k) :: v
  @callback put(t, k, v, put_opts()) :: any()
  @callback del(t, k) :: any()

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
  @spec put(t, k, v, put_opts()) :: any()
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

  defp delegate(%module{} = storage, func, args), do: apply(module, func, [storage | args])
end

defmodule ExKits.Storage.ETS do
  @moduledoc """
  ExKits.Cache.Storage implementation by ETS
  """

  @behaviour ExKits.Cache.Storage

  use GenServer

  alias ExKits.Cache.Storage

  require Logger

  @type t :: %__MODULE__{name: atom(), interval: pos_integer()}

  @enforce_keys ~w{name interval}a

  defstruct @enforce_keys

  @doc """
  create a new ets based storage.
  2 options are supported:
  - name: ets name, default to :ets_cache
  - interval: interval to clean expired keys, default to 60_000 (1 minute)
  """
  @impl Storage
  def new(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:name, :ets_cache)
      |> Keyword.put_new(:interval, 60_000)

    struct(__MODULE__, opts)
  end

  @impl Storage
  def get(storage, key) do
    case :ets.lookup(storage.name, key) do
      [{^key, value, :infinity}] ->
        value

      [{^key, value, timeout}] when is_integer(timeout) ->
        if timeout < :os.system_time(:millisecond) do
          :ets.delete(storage.name, key)
          nil
        else
          value
        end

      _ ->
        nil
    end
  end

  @impl Storage
  def put(storage, key, value, ttl: :infinity), do: :ets.insert(storage.name, {key, value, :infinity})

  def put(storage, key, value, ttl: ttl), do: :ets.insert(storage.name, {key, value, :os.system_time(:millisecond) + ttl})

  def put(storage, key, value, []), do: put(storage, key, value, ttl: :infinity)

  @impl Storage
  def del(storage, key), do: :ets.delete(storage.name, key)

  def child_spec(opts) do
    ets_storage = Keyword.fetch!(opts, :ets_storage)
    %{id: {__MODULE__, ets_storage.name}, start: {__MODULE__, :start_link, [opts]}}
  end

  def start_link(opts) do
    {ets_storage, opts} = Keyword.pop(opts, :ets_storage)
    GenServer.start_link(__MODULE__, ets_storage, opts)
  end

  @impl true
  def init(ets_storage) do
    :ets.new(ets_storage.name, [:named_table, :public, :set])
    Process.send_after(self(), :cleanup, ets_storage.interval)
    {:ok, %{name: ets_storage.name, interval: ets_storage.interval}}
  end

  @impl true
  def handle_info(:cleanup, %{name: name, interval: interval} = state) do
    now = :os.system_time(:millisecond)

    deleted =
      :ets.select_delete(
        name,
        [
          {{:"$1", :"$2", :infinity}, [], [false]},
          {{:"$1", :"$2", :"$3"}, [{:<, :"$3", now}], [true]},
          {:_, [], [false]}
        ]
      )

    Logger.debug("cleanup #{deleted} expired items from #{name}")

    Process.send_after(self(), :cleanup, interval)
    {:noreply, state}
  end
end
