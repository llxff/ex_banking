defmodule ExBanking do
  alias ExBanking.{Accounting, Account, Money}

  @type banking_error :: {:error,
    :wrong_arguments               |
    :user_already_exists           |
    :user_does_not_exist           |
    :not_enough_money              |
    :sender_does_not_exist         |
    :receiver_does_not_exist       |
    :too_many_requests_to_user     |
    :too_many_requests_to_sender   |
    :too_many_requests_to_receiver
  }

  @spec create_user(user::String.t) :: :ok | banking_error
  def create_user(user) when is_binary(user) do
    Accounting.add_account(user)
  end
  def create_user(_user) do
    {:error, :wrong_arguments}
  end

  @spec deposit(user::String.t, amount::number, currency::String.t) :: {:ok, new_balance::number} | banking_error
  def deposit(user, amount, currency)
      when is_binary(user) and is_binary(currency) and is_number(amount) and amount >= 0.0
  do
    with {:ok, account} <- find_account(user) do
      Account.deposit(account, Money.round(amount), currency)
    end
  end
  def deposit(_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  @spec withdraw(user::String.t, amount::number, currency::String.t) :: {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency)
      when is_binary(user) and is_binary(currency) and is_number(amount) and amount >= 0.0
  do
    with {:ok, account} <- find_account(user) do
      Account.withdraw(account, Money.round(amount), currency)
    end
  end
  def withdraw(_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  @spec get_balance(user::String.t, currency::String.t) :: {:ok, balance::number} | banking_error
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    with {:ok, account} <- find_account(user) do
      Account.balance(account, currency)
    end
  end
  def get_balance(_user, _currency) do
    {:error, :wrong_arguments}
  end

  @spec send(from_user::String.t, to_user::String.t, amount::number, currency::String.t) :: {:ok, from_user_balance::number, to_user_balance::number} | banking_error
  def send(user, user, _amount, _currency) do
    {:error, :wrong_arguments}
  end
  def send(from_user, to_user, amount, currency)
      when is_binary(from_user) and is_binary(to_user) and is_binary(currency) and
           is_number(amount) and amount >= 0.0
  do
    with {:ok, sender_account}    <- find_account(from_user, :sender_does_not_exist),
         {:ok, recipient_account} <- find_account(to_user, :receiver_does_not_exist)
    do
      Account.transfer(sender_account, recipient_account, Money.round(amount), currency)
    end
  end
  def send(_from_user, _to_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  defp find_account(user, error \\ :user_does_not_exist) do
    case Accounting.find_account(user) do
      {:ok, pid} -> {:ok, pid}
      _ -> {:error, error}
    end
  end
end
