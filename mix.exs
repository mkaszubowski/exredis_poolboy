defmodule ExredisPoolboy.Mixfile do
  use Mix.Project

  def project do
    [app: :exredis_poolboy,
     version: "0.2.0",
     description: "Wrapper around exredis using poolboy",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :exredis, :poolboy],
     mod: {ExredisPoolboy, []}]
  end

  defp deps do
    [
      {:exredis, ">= 0.2.2"},
      {:poolboy, "~> 1.5"},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Maciej Kaszubowski"],
      files: ["lib", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mkaszubowski/exredis_poolboy"}
    ]
  end
end
