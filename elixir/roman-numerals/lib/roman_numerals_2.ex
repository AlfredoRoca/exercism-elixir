defmodule RomanNumerals2 do
  @doc """
  Convert the number to a roman number.
  """
  @spec numeral(pos_integer) :: String.t()
  def numeral(number) do
    units = number |> Integer.to_string() |> String.slice(-1, 1)
    tens = number |> Integer.to_string() |> String.slice(-2, 1)
    hundreds = number |> Integer.to_string() |> String.slice(-3, 1)
    thousands = number |> Integer.to_string() |> String.slice(-4, 1)

    trans(thousands, "M", "", "") <>
      trans(hundreds, "C", "D", "M") <>
      trans(tens, "X", "L", "C") <>
      trans(units, "I", "V", "X")
  end

  def trans(number, sym_for_1, sym_for_5, sym_for_10) do
    case number do
      number when number in ["", "0"] ->
        ""

      number when number in ["1", "2", "3"] ->
        String.duplicate(sym_for_1, String.to_integer(number))

      "4" ->
        sym_for_1 <> sym_for_5

      "5" ->
        sym_for_5

      number when number in ["6", "7", "8"] ->
        sym_for_5 <> String.duplicate(sym_for_1, String.to_integer(number) - 5)

      "9" ->
        sym_for_1 <> sym_for_10
    end
  end
end
