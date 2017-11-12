defmodule ExBanking.Balance do
  alias ExBanking.Money

  defstruct [:accounts]

  @spec new() :: %__MODULE__{}
  def new do
    %__MODULE__{accounts: %{}}
  end

  @spec amount(%__MODULE__{}, binary) :: number
  def amount(%__MODULE__{accounts: accounts}, currency) do
    Map.get(accounts, currency, 0.0)
  end

  @spec increase(%__MODULE__{}, number, binary) :: {:ok, %__MODULE__{}}
  def increase(%__MODULE__{} = balance, amount, currency) when amount >= 0.0 do
    change(balance, amount, currency)
  end

  @spec decrease(%__MODULE__{}, number, binary) :: {:ok, %__MODULE__{}}
  def decrease(%__MODULE__{} = balance, amount, currency)  when amount >= 0.0 do
    if amount(balance, currency) >= amount do
      change(balance, -amount, currency)
    else
      {:error, :not_enough_money}
    end
  end

  @spec change(%__MODULE__{}, number, binary) :: {:ok, %__MODULE__{}}
  defp change(%__MODULE__{accounts: accounts} = balance, amount, currency) do
    new_amount = amount(balance, currency) + amount
    new_accounts = Map.put(accounts, currency, Money.round(new_amount))

    {:ok, %{balance | accounts: new_accounts}}
  end
end
