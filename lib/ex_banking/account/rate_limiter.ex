defmodule ExBanking.RateLimiter do
  @spec callable?(pid) :: boolean
  def callable?(account) when is_pid(account) do
    mailbox_length(account) < rate_limit()
  end

  @spec mailbox_length(pid) :: number
  defp mailbox_length(pid) do
    {:message_queue_len, len} = Process.info(pid, :message_queue_len)
    len
  end

  @spec rate_limit() :: number
  defp rate_limit do
    Application.get_env(:ex_banking, :account)[:rate_limit] || 10
  end
end
