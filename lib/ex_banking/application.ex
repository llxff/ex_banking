defmodule ExBanking.Application do
  use Application

  alias ExBanking.Accounting

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, ExBanking.AccountsRegistry]),
      supervisor(Accounting, [])
    ]

    opts = [strategy: :one_for_one, name: ExBanking.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
