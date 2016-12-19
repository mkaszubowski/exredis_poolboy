defmodule ExredisPoolboy.FunctionsDefinitions do
  defmacro __using__(config_key \\ nil) do
    exredis_api_functions =
      :functions
      |> Exredis.Api.__info__()
      |> Enum.map(fn {name, arity} ->
        args = create_args(arity)

        quote do
          def unquote(name)(unquote_splicing(args)) do
            pool_name  =
              case unquote(config_key) do
                nil -> :exredis_poolboy_pool
                _ ->
                  Application.get_env(unquote(config_key), :pool_name, :exredis_poolboy_pool)
              end

            :poolboy.transaction(pool_name, fn worker ->
              GenServer.call(worker, {unquote(name), unquote(args)})
            end)
          end

        end
      end)

    query_function =
      quote do
        def query(command) do
          pool_name  =
            case unquote(config_key) do
              nil -> :exredis_poolboy_pool
              _ ->
                Application.get_env(unquote(config_key), :pool_name, :exredis_poolboy_pool)
            end

          :poolboy.transaction(pool_name, fn worker ->
            GenServer.call(worker, {:query, command})
          end)
        end
      end

    overridable =
      quote do
        defoverridable Exredis.Api.__info__(:functions)
        defoverridable [query: 1]
      end

    exredis_api_functions ++ [query_function] ++ [overridable]
  end


  defp create_args(0), do: []
  defp create_args(arity) do
    Enum.map((1..arity), &Macro.var(:"arg-#{&1}", __MODULE__))
  end
end
