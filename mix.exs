defmodule Paywizard.MixProject do
  use Mix.Project

  def project do
    [
      app: :paywizard,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:httpoison, "~> 1.6"},
      {:elixir_uuid, "~> 1.2"}
    ]
  end
end
