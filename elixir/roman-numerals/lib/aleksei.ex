defmodule RomanNumerals do
  require Integer
  @romans 'IVXLCDM'

  @spec numeral(pos_integer()) :: String.t()
  def numeral(number, romans \\ @romans) do
    fours = fn
      <<c, c, c, c>>, [last], _f -> <<c, last>>
      <<c, c, c, c>>, [c, next | _], _f -> <<c, next>>
      <<next, c, c, c, c>>, [c, next, result | _], _f -> <<c, result>>
      <<some, c, c, c, c>>, [c, next | _], _f -> <<some, c, next>>
      input, [_ | next], f -> f.(input, next, f)
    end

    romans
    |> Enum.with_index()
    |> Enum.reverse()
    |> Enum.reduce({number, []}, fn {c, i}, {number, acc} ->
      denominator =
        round(
          if Integer.is_even(i),
            do: :math.pow(10, i / 2),
            else: 5 * :math.pow(10, (i - 1) / 2)
        )

      {
        rem(number, denominator),
        acc ++ List.duplicate(c, div(number, denominator))
      }
    end)
    |> elem(1)
    |> to_string()
    |> String.replace(~r/.?(.)\1\1\1/, fn m -> fours.(m, romans, fours) end)
  end
end
