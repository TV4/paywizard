defmodule Singula.MixProject do
  use Mix.Project

  def project do
    [
      app: :singula,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: ["test.watch": :test],
      aliases: [smoke: &run_smoke_tests(&1)]
    ]
  end

  def run_smoke_tests(args) do
    IO.puts("Running smoke tests")

    {_, res} =
      System.cmd("mix", ~w(test smoke_test --color --trace --seed 0 --max-failures 1) ++ args,
        into: IO.binstream(:stdio, :line),
        env: [{"MIX_ENV", "dev"}]
      )

    if res > 0 do
      System.at_exit(fn _ -> exit({:shutdown, 1}) end)
    end
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:elixir_uuid, "~> 1.2"},
      {:timex, "~> 3.6"},
      {:telemetry, "~> 0.4.2"},
      {:httpoison, "~> 1.6", optional: true},
      {:mix_test_watch, "~> 1.0", only: :test},
      {:hammox, "~> 0.2", only: [:dev, :test]}
    ]
  end
end
