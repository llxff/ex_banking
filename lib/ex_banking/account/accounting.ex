defmodule ExBanking.Accounting do
  use Supervisor

  alias ExBanking.Account

  @registry ExBanking.AccountsRegistry

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [supervisor(Account, [])]

    supervise(children, strategy: :simple_one_for_one, restart: :transient)
  end

  @spec add_account(binary) :: :ok | {:error, :user_already_exists}
  def add_account(user) do
    case Supervisor.start_child(__MODULE__, [account_name(user)]) do
      {:ok, _pid} ->
        :ok
      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end

  @spec find_account(binary) :: {:ok, pid} | {:error, :user_does_not_exist}
  def find_account(user) do
    case Registry.lookup(@registry, user) do
      [{pid, _}] -> {:ok, pid}
      _ -> {:error, :user_does_not_exist}
    end
  end

  @spec account_name(binary) :: {:via, atom, {atom, binary}}
  defp account_name(user) do
    {:via, Registry, {@registry, user}}
  end
end
