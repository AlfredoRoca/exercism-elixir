defmodule RomanNumerals do
  @doc """
  Convert the number to a roman number.
  """
  @spec numeral(pos_integer) :: String.t()
  def numeral(number) do
    numeral(number, 'IVXLCDMEFGHJ')
  end

  def numeral(number, romans) do
    conversion = get_conversion_table(romans)

    fours = get_fours(conversion)
    nines = get_nines(conversion)

    (conversion ++ fours ++ nines)
    |> Enum.sort_by(&Map.values/1)
  end

  def get_conversion_table(romans) do
    ones =
      Enum.take_every(romans, 2)
      |> Enum.with_index()
      |> Enum.map(fn {s, i} -> %{[s] => trunc(:math.pow(10, i))} end)
      |> IO.inspect(label: "25")

    [_t | h] = romans

    fives =
      h
      |> Enum.take_every(2)
      |> Enum.with_index()
      |> Enum.map(fn {s, i} -> %{[s] => trunc(5 * :math.pow(10, i))} end)
      |> IO.inspect(label: "33")

    Enum.zip(ones, fives) |> Enum.map(&Tuple.to_list/1) |> List.flatten()
  end

  def get_fours(conversion_table) do
    conversion_table
    |> Enum.chunk_every(2)
    |> Enum.flat_map(fn [u, f] ->
      %{
        Enum.join(Map.keys(u) ++ Map.keys(f)) =>
          List.first(Map.values(f)) - List.first(Map.values(u))
      }
    end)
  end

  def get_nines(conversion_table) do
    conversion_table
    |> Enum.chunk_every(2)
    |> Enum.flat_map(fn [u, f] ->
      %{
        Enum.join(Map.keys(u) ++ Map.keys(f)) =>
          List.first(Map.values(f)) - List.first(Map.values(u))
      }
    end)
  end
end
