defmodule ExBanking.Account do
  use GenServer

  alias ExBanking.{
    Balance,
    WithdrawalOperation,
    DepositOperation,
    TransferOperation,
    BalanceOperation,
    RateLimiter
  }

  @type balance :: {:ok, number}
  @type rate_limit_error :: {:error, :too_many_requests_to_user}
  @type transfer_limit_error :: {:error, :too_many_requests_to_sender | :too_many_requests_to_receiver}
  @type not_enough_money_error :: {:error, :not_enough_money}

  def start_link(name) do
    GenServer.start_link(__MODULE__, Balance.new(), name: name)
  end

  def init(balance) do
    {:ok, balance}
  end

  @spec balance(pid, binary) :: balance | rate_limit_error
  def balance(account, currency) do
    run(account, %BalanceOperation{currency: currency})
  end

  @spec withdraw(pid, number, binary) :: balance | rate_limit_error | not_enough_money_error
  def withdraw(account, amount, currency) do
    run(account, %WithdrawalOperation{amount: amount, currency: currency})
  end

  @spec deposit(pid, number, binary) :: balance | rate_limit_error
  def deposit(account, amount, currency) do
    run(account, %DepositOperation{amount: amount, currency: currency})
  end

  @spec transfer(pid, pid, number, binary) :: {:ok, number, number} | {:error, :wrong_arguments} | transfer_limit_error
  def transfer(account, account, _amount, _currency) do
    {:error, :wrong_arguments}
  end
  def transfer(sender, recipient, amount, currency) do
    with operation <- %TransferOperation{recipient: recipient, amount: amount, currency: currency},
         {:ok, _, _} = result <- run(sender, operation)
    do
      result
    else
      {:error, :too_many_requests_to_user} ->
        {:error, :too_many_requests_to_sender}
      error ->
        error
    end
  end

  def handle_call(
    %BalanceOperation{currency: currency},
    _from,
    balance
  ) do
    {:reply, {:ok, Balance.amount(balance, currency)}, balance}
  end

  def handle_call(
    %WithdrawalOperation{amount: amount, currency: currency},
    _from,
    balance
  ) do
    case Balance.decrease(balance, amount, currency) do
      {:ok, new_balance} ->
        {:reply, {:ok, Balance.amount(new_balance, currency)}, new_balance}
      error ->
        {:reply, error, balance}
    end
  end

  def handle_call(
    %DepositOperation{amount: amount, currency: currency},
    _from,
    balance
  ) do
    case Balance.increase(balance, amount, currency) do
      {:ok, new_balance} ->
        {:reply, {:ok, Balance.amount(new_balance, currency)}, new_balance}
      error ->
        {:reply, error, balance}
    end
  end

  def handle_call(
    %TransferOperation{recipient: recipient, amount: amount, currency: currency},
    _from,
    balance
  ) do
    with {:ok, sender_balance}   <- Balance.decrease(balance, amount, currency),
         {:ok, recipient_amount} <- __MODULE__.deposit(recipient, amount, currency),
         sender_amount           <- Balance.amount(sender_balance, currency)
    do
      {:reply, {:ok, sender_amount, recipient_amount}, sender_balance}
    else
      {:error, :too_many_requests_to_user} ->
        {:reply, {:error, :too_many_requests_to_receiver}, balance}
      error ->
        {:reply, error, balance}
    end
  end

  @spec run(pid, struct) :: tuple
  defp run(account, operation) do
    if RateLimiter.callable?(account) do
      GenServer.call(account, operation)
    else
      {:error, :too_many_requests_to_user}
    end
  end
end
