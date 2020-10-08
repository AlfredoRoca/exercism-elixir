defmodule Sieve do
  @doc """
  Generates a list of primes up to a given limit.
  """
  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(limit) do
    {_d, {primes, _non_primes}} =
      2..limit
      |> Enum.map_reduce({[], []}, fn n, {primes, non_primes} ->
        if(Enum.member?(non_primes, n)) do
          {n, {primes, non_primes}}
        else
          {n,
           {[n | primes],
            [Enum.map(1..(div(limit, n) + 1), &(n * &1)) | non_primes] |> List.flatten()}}
        end
      end)

    Enum.reverse(primes)
  end
end
