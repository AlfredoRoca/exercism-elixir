defmodule Bob do
  def hey(input) do
    cond do
      String.trim(input) == "" ->
        "Fine. Be that way!"

      all_capital_letters(input) && is_a_question(input) ->
        "Calm down, I know what I'm doing!"

      all_capital_letters(input) ->
        "Whoa, chill out!"

      is_a_question(input) ->
        "Sure."

      true ->
        "Whatever."
    end
  end

  def all_capital_letters(input),
    do: String.upcase(input) === input && Regex.run(~r/[\d\s?):.,]+/, input) != [input]

  def is_a_question(input), do: String.ends_with?(String.trim(input), "?")
end
