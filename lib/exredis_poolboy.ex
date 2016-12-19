defmodule ExredisPoolboy do
  use Application

  use ExredisPoolboy.FunctionsWrapper

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
    ]

    opts = [strategy: :one_for_one, name: ExredisPoolboy.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
