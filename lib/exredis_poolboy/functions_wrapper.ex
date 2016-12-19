defmodule ExredisPoolboy.FunctionsWrapper do
  defmacro __using__(_args) do
    :functions
    |> Exredis.Api.__info__()
    |> Enum.map(fn {name, arity} ->
      args = create_args(arity)

      quote do
        def unquote(name)(unquote_splicing(args)) do
          :poolboy.transaction(:exredis_poolboy_pool, fn worker ->
            GenServer.call(worker, {unquote(name), unquote(args)})
          end)
        end
      end
    end)
  end


  defp create_args(0), do: []
  defp create_args(arity) do
    Enum.map((1..arity), &Macro.var(:"arg-#{&1}", __MODULE__))
  end
end
