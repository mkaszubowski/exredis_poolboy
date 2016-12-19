defmodule ExredisPoolboy.Worker do
  @moduledoc """
  Worker module. Passes all the functions to exredis.
  """
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init({:config_key, key}) do
    {:ok, %{client: nil, config_key: key}}
  end

  def handle_call({:query, command}, _from, state) do
    c = get_or_create_client(state)
    res = Exredis.query(c, command)

    new_state = %{state | client: c}
    {:reply, res, new_state}
  end
  def handle_call({fun, params}, _from, state) when is_list(params) do
    c = get_or_create_client(state)
    params = [c | params]
    res = apply(Exredis.Api, fun, params)

    new_state = %{state | client: c}
    {:reply, res, new_state}
  end

  defp get_or_create_client(%{client: nil, config_key: config_key}) do
    config = Application.fetch_env!(config_key, :redis)
    {:ok, client} =
      Exredis.start_link(
        config[:host],
        config[:port] |> to_int,
        config[:db],
        config[:password],
        config[:reconnect]
      )
    client
  end

  defp get_or_create_client(%{client: client, config_key: config_key}) do
    case Process.alive?(client) do
      false -> get_or_create_client(%{client: nil, config_key: config_key})
      true -> client
    end
  end

  defp to_int(i) when is_integer(i), do: i
  defp to_int(s), do: String.to_integer(s)
end
