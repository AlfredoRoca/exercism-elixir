defmodule RomanNumerals1 do
  @doc """
  Convert the number to a roman number.
  """
  @spec numeral(pos_integer) :: String.t()
  def numeral(number) do
    units = number |> Integer.to_string() |> String.slice(-1, 1)
    tens = number |> Integer.to_string() |> String.slice(-2, 1)
    tens = if tens == "", do: tens, else: tens <> "0"
    hundreds = number |> Integer.to_string() |> String.slice(-3, 1)
    hundreds = if hundreds == "", do: hundreds, else: hundreds <> "00"
    thousands = number |> Integer.to_string() |> String.slice(-4, 1)
    thousands = if thousands == "", do: thousands, else: thousands <> "000"

    convert(units, tens, hundreds, thousands)
  end

  # def convert("1"), do: "I"
  # def convert("2"), do: "II"
  # def convert("3"), do: "III"
  # def convert("4"), do: "IV"
  # def convert("5"), do: "V"
  # def convert("6"), do: "VI"
  # def convert("7"), do: "VII"
  # def convert("8"), do: "VIII"
  # def convert("9"), do: "IX"
  def convert(""), do: ""

  def convert(units, tens, hundreds, thousands) do
    sym_units = %{
      "1" => "I",
      "2" => "II",
      "3" => "III",
      "4" => "IV",
      "5" => "V",
      "6" => "VI",
      "7" => "VII",
      "8" => "VIII",
      "9" => "IX",
      "0" => ""
    }

    sym_tens = %{
      "10" => "X",
      "20" => "XX",
      "30" => "XXX",
      "40" => "XL",
      "50" => "L",
      "60" => "LX",
      "70" => "LXX",
      "80" => "LXXX",
      "90" => "XC",
      "00" => "",
      "" => ""
    }

    sym_hundreds = %{
      "100" => "C",
      "200" => "CC",
      "300" => "CCC",
      "400" => "CD",
      "500" => "D",
      "600" => "DC",
      "700" => "DCC",
      "800" => "DCCC",
      "900" => "CM",
      "000" => "",
      "" => ""
    }

    sym_thousands = %{
      "1000" => "M",
      "2000" => "MM",
      "3000" => "MMM",
      "" => ""
    }

    {_, conv_units} = Map.fetch(sym_units, units)
    {_, conv_tens} = Map.fetch(sym_tens, tens)
    {_, conv_hundreds} = Map.fetch(sym_hundreds, hundreds)
    {_, conv_thousands} = Map.fetch(sym_thousands, thousands)

    conv_thousands <> conv_hundreds <> conv_tens <> conv_units
  end
end
