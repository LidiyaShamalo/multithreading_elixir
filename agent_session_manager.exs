defmodule SessionManager do

  defmodule Session do
    @type t :: %Session{
      username: String.t(),
      shard: non_neg_integer(),
      node: String.t()
    }

    defstruct [:username, :shard, :node]
  end

  @spec start() :: {:ok, pid()}
  def start() do
    initial_state = []
    Agent.start(fn() -> initial_state end)
  end

  @spec stop(pid()) :: :ok
  def stop(pid) do
    Agent.stop(pid)
  end

  @spec add_session(pid(), String.t()) :: :ok
  def add_session(pid, username) do
    {shard, node} = ShardManager.settle(username)
    session = %Session{username: username, shard: shard, node: node}
    Agent.update(pid, fn(state) -> [session | state] end)
    :ok
  end

  @spec get_sessions(pid()) :: [Session.t()]
  def get_sessions(pid) do
    Agent.get(pid, fn(state) -> state end)
  end

  @spec find_session_by_name(pid(), String.t()) :: {:ok, Session.t()} | {:error, :not_found}
  def find_session_by_name(pid, username) do
    Agent.get(pid, fn(state) -> find_session(state, username) end)
  end

  #works inside Agent process
  @spec find_session([Session.t()], String.t()) :: {:ok, Session.t()} | {:error, :not_found}
  def find_session(state, username) do
    Enum.find(state, fn(session) -> session.username == username end)
    |> case do
      %Session{} = s -> {:ok, s}
      nil -> {:error, :not_found}
    end
  end

end
