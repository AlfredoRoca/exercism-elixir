defmodule BankAccount1 do
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
    spawn(fn ->
      state = %{status: :open, transactions: []}
      loop(state)
    end)
  end

  defp loop(state) do
    new_state =
      receive do
        {:calculate_balance, caller} ->
          if state.status == :open do
            send(
              caller,
              {:balance, Enum.reduce(state.transactions, 0, fn tr, acc -> tr.amount + acc end)}
            )
          else
            send(caller, {:error, :account_closed})
          end

          state

        {:update, caller, amount} ->
          if state.status == :open do
            new_state =
              Map.replace!(state, :transactions, state.transactions ++ [%{amount: amount}])

            send(caller, {:ok, :updated})
            new_state
          else
            send(caller, {:error, :account_closed})
            state
          end

        {:close} ->
          Map.replace!(state, :status, :closed)
      end

    loop(new_state)
  end

  @doc """
  Close the bank. Makes the account unavailable.
  """
  @spec close_bank(account) :: pid()
  def close_bank(account) do
    send(account, {:close})
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer
  def balance(account) do
    send(account, {:calculate_balance, self()})

    receive do
      {:balance, balance} -> balance
      message -> message
    end
  end

  @doc """
  Update the account's balance by adding the given amount which may be negative.
  """
  @spec update(account, integer) :: any
  def update(account, amount) do
    send(account, {:update, self(), amount})

    receive do
      message -> message
    end
  end
end
