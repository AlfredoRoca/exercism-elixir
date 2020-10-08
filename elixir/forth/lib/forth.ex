defmodule Forth do
  @type evaluator :: any
  @operators String.split("+-*/", "", trim: true)
  @reserved_words String.split("DUP DROP SWAP OVER")

  @doc """
  Create a new evaluator.
  """
  @spec new() :: evaluator
  def new() do
    Forth.NewWords.new()
    push_reserved_words_to_dictionary()
    %{stack: []}
  end

  def push_reserved_words_to_dictionary do
    @reserved_words |> Enum.each(&Forth.NewWords.put(&1, &1))
  end

  @doc """
  Evaluate an input string, updating the evaluator state.
  """
  @spec eval(evaluator, String.t()) :: evaluator
  def eval(%{stack: stack}, s) do
    cond do
      Regex.match?(~r": .+ ;", s) ->
        [[": ", new_word, " ", translation, " ;"]] =
          Regex.scan(~r"(: )([a-zA-Z-]+)( )([a-zA-Z-\s]+)( ;)", s, capture: :all_but_first)

        Forth.NewWords.put(new_word, translation)
        %{stack: stack}

      true ->
        ev = String.split(s, " ")
        %{stack: parse(ev, stack)}
    end

    # |> String.split(~r{[\x00-\x30\u1680]}, trim: true)
  end

  def parse(ev, stack) do
    Enum.reduce(ev, stack, fn h, st ->
      do_parse(h, st)
    end)
    |> Enum.reverse()
  end

  def do_parse(h, stack) do
    cond do
      Regex.match?(~r/[0-9]/, h) ->
        # push number to the stack
        [h | stack]

      Enum.member?(@operators, h) ->
        # run operation
        [n2 | [n1 | remaining_stack]] = stack
        [run_op(String.to_integer(n1), String.to_integer(n2), h) | remaining_stack]

      is_nil(translate_word(h)) ->
        stack

      true ->
        Enum.reduce(translate_word(h), stack, fn w, st ->
          if Enum.member?(@reserved_words, w) do
            # execute reserved word
            run_word(w, st)
          else
            do_parse(w, st)
          end
        end)
    end
  end

  def translate_word(h) do
    case tr = h |> String.upcase() |> Forth.NewWords.translate() do
      nil -> nil
      _ -> String.split(tr, " ")
    end
  end

  def run_op(n1, n2, "+"), do: Integer.to_string(n1 + n2)
  def run_op(n1, n2, "-"), do: Integer.to_string(n1 - n2)
  def run_op(n1, n2, "*"), do: Integer.to_string(n1 * n2)

  def run_op(n1, n2, "/") do
    try do
      Integer.to_string(div(n1, n2))
    rescue
      ArithmeticError ->
        raise Forth.DivisionByZero
    end
  end

  @spec run_word(evaluator) :: evaluator
  def run_word("DUP", []), do: raise(Forth.StackUnderflow)
  def run_word("DUP", [h | _rest] = stack), do: [h | stack]
  def run_word("DROP", []), do: raise(Forth.StackUnderflow)
  def run_word("DROP", [_h | rest]), do: rest
  def run_word("SWAP", []), do: raise(Forth.StackUnderflow)
  def run_word("SWAP", [_h | []]), do: raise(Forth.StackUnderflow)
  def run_word("SWAP", [h1 | [h2 | rest]]), do: [h2 | [h1 | rest]]
  def run_word("OVER", []), do: raise(Forth.StackUnderflow)
  def run_word("OVER", [_h | []]), do: raise(Forth.StackUnderflow)
  def run_word("OVER", [h1 | [h2 | rest]]), do: [h2 | [h1 | [h2 | rest]]]
  def run_word(stack), do: stack

  @doc """
  Return the current stack as a string with the element on top of the stack
  being the rightmost element in the string.
  """
  @spec format_stack(evaluator) :: String.t()
  def format_stack(%{stack: []}), do: ""

  def format_stack(%{stack: stack}) do
    Enum.join(stack, " ")
  end

  defmodule NewWords do
    use Agent

    def new() do
      case Agent.start_link(fn -> %{} end, name: __MODULE__) do
        {:ok, dictionary} ->
          dictionary

        {:error, _} ->
          Agent.stop(__MODULE__)
          new()
      end
    end

    def put(word, translation) do
      Agent.update(__MODULE__, &Map.put(&1, String.upcase(word), String.upcase(translation)))
    end

    def translate(word) do
      Agent.get(__MODULE__, &Map.get(&1, word))
    end
  end

  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception word: nil
    def message(e), do: "invalid word: #{inspect(e.word)}"
  end

  defmodule UnknownWord do
    defexception word: nil
    def message(e), do: "unknown word: #{inspect(e.word)}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end
end
