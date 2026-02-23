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

  def start() do
    nodes = ["node-1", "node-2", "node-3", "node-4" ]
    start(nodes, 32)
  end

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
  end

end
