defmodule ExredisPoolboy.Mixfile do
  use Mix.Project

  def project do
    [app: :exredis_poolboy,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :exredis, :poolboy],
     mod: {ExredisPoolboy, []}]
  end

  defp deps do
    [
      {:exredis, ">= 0.2.2"},
      {:poolboy, "~> 1.5"}
    ]
  end
end
