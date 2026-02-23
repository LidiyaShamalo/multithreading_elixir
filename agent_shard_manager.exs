defmodule ShardManager do

  defmodule ShardRange do
    @type t() :: %ShardRange{
      node: String.t(),
      from_shard: pos_integer(),
      to_shard: pos_integer()
    }

    defstruct [:node, :from_shard, :to_shard]
  end

  defmodule State do
    @type t() :: %State{
      num_shards: pos_integer(),
      shard_ranges: [ShardRange.t()]
    }

    defstruct [:num_shards, :shard_ranges]
  end

  @spec start() :: State.t()
  def start() do
    nodes = ["node-1", "node-2", "node-3", "node-4" ]
    start(nodes, 32)
  end

  @spec start([String.t()], pos_integer()) :: State.t()
  def start(nodes, num_shards) do
    num_nodes = length(nodes)
    shards_per_node = ceil(num_shards / num_nodes)
    {num_nodes, shards_per_node}
    {_, ranges} = Enum.reduce(nodes, {1, []},
    fn(node, {from_shard, acc}) ->
      to_shard = from_shard + shards_per_node - 1
      to_shard = if to_shard > num_shards, do: num_shards, else: to_shard
      range = %ShardRange{node: node, to_shard: to_shard, from_shard: from_shard}
      {to_shard + 1, [range | acc]}
    end)
    state = %State{num_shards: num_shards, shard_ranges: ranges}
    Agent.start(fn() -> state end, [name: :shard_manager]) #второй параметр список опций - имя процесса
    state
  end

  @spec get_node(pos_integer()) :: {:ok, String.t() | {:error, :not_found}}
  def get_node(shard) do
    Agent.get(:shard_manager, fn(state) -> get_node(state, shard) end)
  end

  @spec get_node(State.t(), pos_integer()) :: {:ok, String.t()} | {:error, :not_found}
  defp get_node(state, shard) do
    Enum.filter(state.shard_ranges,
    fn(%ShardRange{from_shard: from, to_shard: to}) ->
      shard >= from and shard <= to
    end)
    |> case do
      [] -> {:error, :not_found}
      [%ShardRange{node: node}] -> {:ok, node}
    end
  end

  #вычисление shard и node для пользователя
  @spec settle(String.t()) :: {pos_integer(), String.t()}
  def settle(username) do
    num_shards = Fgent.get(:shard_manager, fn(state) -> state.num_shards end)
    shard = :erlang.phash2(username, num_shards) + 1
    {:ok, node} = get_node(shard)
    {shard, node}
  end
end

#Agent.get(:shard_manager, fn(state) -> state end) - выводит State
