defmodule ExredisPoolboy.PoolSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init({:config_key, key} = args) do
    pool_options = [
      name: {:local, get_name(key)},
      worker_module: ExredisPoolboy.Worker,
      size: get_pool_size(key),
      max_overflow: 5
    ]

    children = [
      :poolboy.child_spec(get_name(key), pool_options, args),
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp get_name(config_key) do
    Application.get_env(config_key, :pool_name, :exredis_poolboy_pool)
  end

  defp get_pool_size(config_key) do
    case Application.get_env(config_key, :pool) do
      nil                        -> 10
      ""                         -> 10
      size when is_binary(size)  -> String.to_integer(size)
      size when is_integer(size) -> size
    end
  end
end
