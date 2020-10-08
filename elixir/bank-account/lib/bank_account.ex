defmodule BankAccount do
  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  @doc """
  Open the bank. Makes the account available.
  """
  @spec open_bank() :: account
  def open_bank() do
    {:ok, account} = Agent.start_link(fn -> %{status: :open, transactions: []} end)
    account
  end

  @doc """
  Close the bank. Makes the account unavailable.
  """
  @spec close_bank(account) :: pid()
  def close_bank(account) do
    Agent.update(account, &Map.replace!(&1, :status, :closed))
    account
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer
  def balance(account) do
    if is_open?(account) do
      Enum.reduce(get_transactions(account), 0, fn tr, acc -> tr.amount + acc end)
    else
      {:error, :account_closed}
    end
  end

  @doc """
  Update the account's balance by adding the given amount which may be negative.
  """
  @spec update(account, integer) :: any
  def update(account, amount) do
    if is_open?(account) do
      Agent.update(account, &add_new_transactions(&1, amount))
    else
      {:error, :account_closed}
    end
  end

  defp is_open?(account), do: Agent.get(account, &Map.get(&1, :status)) == :open
  defp get_transactions(account), do: Agent.get(account, &Map.get(&1, :transactions))
  defp transaction(amount), do: %{amount: amount}

  defp add_new_transactions(account_state, amount) do
    {_, new_state} =
      Map.get_and_update!(account_state, :transactions, fn current ->
        {current, current ++ [transaction(amount)]}
      end)

    new_state
  end
end
