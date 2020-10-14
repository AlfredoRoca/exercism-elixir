defmodule Forth do
  @type evaluator :: any
  @operators String.split("+-*/", "", trim: true)
  @reserved_words "DUP DROP SWAP OVER"

  def start(_start_type, _start_args) do
    # __MODULE__.new() |> __MODULE__.eval("1 foo") |> __MODULE__.format_stack()
    Supervisor.start_link([], strategy: :one_for_one)
  end

  @doc """
  Create a new evaluator.
  """
  @spec new() :: evaluator
  def new() do
    %{
      stack: [],
      dictionary: initialize_dictionary()
    }
  end

  def initialize_dictionary() do
    @reserved_words
    |> String.split()
    |> Enum.reduce(%{}, &Map.put(&2, &1, &1))
  end

  @doc """
  Evaluate an input string, updating the evaluator state.
  """
  @spec eval(evaluator, String.t()) :: evaluator
  def eval(ev = %{stack: stack, dictionary: dictionary}, s) do
    s = String.upcase(s)

    cond do
      Regex.match?(~r": .+ ;", s) ->
        [[": ", new_word, " ", translation, " ;", rest]] =
          Regex.scan(~r"(: )([€\da-zA-Z-]+)( )([\da-zA-Z-\s]+)( ;)(.*)", s,
            capture: :all_but_first
          )

        case Integer.parse(new_word) do
          {_number, ""} -> raise Forth.InvalidWord
          _ -> nil
        end

        new_dictionary = Map.put(dictionary, new_word, translation)

        case String.trim(rest) do
          "" -> %{ev | dictionary: new_dictionary}
          _ -> eval(%{ev | dictionary: new_dictionary}, rest)
        end

      true ->
        # separators are non-word simbols except operators and special characters
        items = String.split(s, ~r"[^\w-+*/€]|[ ]", trim: true)
        parse(items, %{ev | stack: stack})
    end
  end

  # def parse(items, ev = %{stack: stack, dictionary: dictionary}) do
  def parse(items, ev = %{stack: stack, dictionary: _dictionary}) do
    Enum.reduce(items, stack, fn item, st ->
      do_parse(item, %{ev | stack: st})
    end)
    |> Enum.reverse()
  end

  def do_parse("", ev), do: ev

  def do_parse(item, ev = %{stack: stack, dictionary: dictionary}) do
    cond do
      Regex.match?(~r/[0-9]/, item) ->
        # push number to the stack
        [item | stack]

      Enum.member?(@operators, item) ->
        # run operation
        [n2 | [n1 | remaining_stack]] = stack
        [run_op(String.to_integer(n1), String.to_integer(n2), item) | remaining_stack]

      true ->
        case translation = Map.get(dictionary, item) do
          nil -> raise Forth.UnknownWord
          _ -> nil
        end

        translation
        |> String.split()
        |> Enum.reduce(stack, fn word, st ->
          cond do
            is_nil(word) ->
              raise Forth.UnknownWord

            String.contains?(@reserved_words, word) ->
              # execute reserved word
              run_word(word, st)

            true ->
              do_parse(word, %{ev | stack: st})
          end
        end)
    end
  end

  def translate_word(word) do
    case tr = word |> String.upcase() |> Forth.NewWords.translate() do
      nil -> raise Forth.UnknownWord
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
  def format_stack(%{stack: stack}), do: Enum.join(stack, " ")
  def format_stack(stack), do: Enum.join(stack, " ")

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
      if Regex.match?(~r"[0-9]+", word) do
        # numbers as new words are not allowed
        raise(Forth.InvalidWord)
      else
        Agent.update(__MODULE__, &Map.put(&1, String.upcase(word), String.upcase(translation)))
      end
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
