defmodule ExredisPoolboy.PoolSupervisor do
  use Supervisor

  @name Application.get_env(:exredis_poolboy, :pool_name, :exredis_poolboy_pool)

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    pool_options = [
      name: {:local, @name},
      worker_module: ExredisPoolboy.Worker,
      size: get_pool_size(),
      max_overflow: 5
    ]

    children = [
      :poolboy.child_spec(@name, pool_options, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp get_pool_size do
    case Application.get_env(:exredis_poolboy, :pool) do
      nil                        -> 10
      ""                         -> 10
      size when is_binary(size)  -> String.to_integer(size)
      size when is_integer(size) -> size
    end
  end
end
