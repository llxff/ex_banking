defmodule ExBanking.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_banking,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: [espec: :test],
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {ExBanking.Application, []}]
  end

  defp deps do
    [
      {:espec, "~> 1.4.6", only: :test},
      {:mock, "~> 0.2.0", only: :test}
    ]
  end

  defp aliases do
    ["test": ["espec"]]
  end
end
