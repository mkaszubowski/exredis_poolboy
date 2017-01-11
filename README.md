# ExredisPoolboy

This package is basically a wrapper around [exredis](https://github.com/artemeff/exredis) with [poolboy](https://github.com/devinus/poolboy).
The main goal was to be able to use all Exredis.Api functions which automatically use workers from the worker pool.

## Installation

  1. Add `exredis_poolboy` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:exredis_poolboy, "~> 0.2.0"}]
    end
    ```

  2. Ensure `exredis_poolboy` is started before your application:

    ```elixir
    def application do
      [applications: [:exredis_poolboy]]
    end
    ```

## Usage

  1. Add `ExredisPoolboy.PoolSupervisor` to your supervision tree and provide application config key as an argument:

  ```elixir
  children = [
    supervisor(ExredisPoolboy.PoolSupervisor, [config_key: :my_app_redis])
  ]
  ```

  2. Create a module for using the exredis functions:

  ```elixir
  defmodule MyApp.Redis do
    use ExredisPoolboy.FunctionsDefinitions, :my_app_redis
  end
  ```

  3. Add config:

  ```elixir
  # The fields for redis matches the exredis configuration
  config :my_app_redis, :redis,
    host: "redis",
    port: 6379,
    password: "",
    db: 0,
    reconnect: :no_reconnect,
    max_queue: :infinity

  # Any name works here, used to create different connection pools if needed
  config :my_app_redis, :pool_name, :my_app_redis_pool

  # Optional, defaults to 10
  config :my_app_redis, :pool, 20
  ```

  4. Use just like you would use exredis:

  ```elixir
     MyApp.Redis.llen("key")
     MyApp.Redis.sadd("key", "value")
  ```
  
  ## Overriding functions
  
  All functions are marked as overridable so you can extend basic functions, for example:
  
  ```elixir
  defmodule MyApp.Redis do
    use ExredisPoolboy.FunctionsDefinitions, :my_app_redis
    
    def llen(key) do
      key
      |> super()
      |> String.to_integer()
    end
  end
  ```
  
  ## TODO
  
  - Add support for `only`/`except` with `use ExredisPoolboy.FunctionsDefinitions`
  - Allow using functions on ExredisPoolboy module directly (without need to start separate supervisor), e.g. `ExredisPoolboy.llen("key")`
