defmodule ExredisPoolboy.Worker do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, %{client: nil}}
  end

  def handle_call({function_name, params} = tupple, _from, %{client: c}) when is_list(params) do
    c = get_or_create_client(c)
    params = [c | params]
    res = apply(Exredis.Api, function_name, params)
    {:reply, res, %{client: c}}
  end

  defp get_or_create_client(nil) do
    config = Application.fetch_env!(:exredis_poolboy, :redis)
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
  defp get_or_create_client(client) do
    case Process.alive?(client) do
      false -> get_or_create_client(nil)
      true -> client
    end
  end

  defp to_int(i) when is_integer(i), do: i
  defp to_int(s), do: String.to_integer(s)
end
