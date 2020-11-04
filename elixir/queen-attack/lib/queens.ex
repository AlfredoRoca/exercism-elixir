defmodule Queens do
  @type t :: %Queens{black: {integer, integer}, white: {integer, integer}}
  defstruct [:white, :black]

  def empty_board,
    do:
      String.trim("""
      _ _ _ _ _ _ _ _
      _ _ _ _ _ _ _ _
      _ _ _ _ _ _ _ _
      _ _ _ _ _ _ _ _
      _ _ _ _ _ _ _ _
      _ _ _ _ _ _ _ _
      _ _ _ _ _ _ _ _
      _ _ _ _ _ _ _ _
      """)
      |> String.split("\n")

  @doc """
  Creates a new set of Queens
  """
  @spec new(Keyword.t()) :: Queens.t()
  def new(opts \\ []) do
    case validate(opts) do
      {:error} ->
        raise(ArgumentError)

      {:ok} ->
        handle_result(opts)
    end
  end

  def handle_result([white: white] = _opts), do: %Queens{white: white}
  def handle_result([black: black] = _opts), do: %Queens{black: black}
  def handle_result([white: white, black: black] = _opts), do: %Queens{white: white, black: black}

  def validate(), do: {:error}
  def validate({}), do: {:error}
  def validate([]), do: {:error}
  def validate(white: pos), do: validate_pos(pos)
  def validate(black: pos), do: validate_pos(pos)
  def validate(white: same_pos, black: same_pos), do: {:error}
  def validate(black: same_pos, white: same_pos), do: {:error}

  def validate(white: white, black: black) do
    if validate_pos(white) == {:error} or validate_pos(black) == {:error} do
      {:error}
    else
      {:ok}
    end
  end

  def validate(opts) do
    if Enum.all?(Keyword.keys(opts), fn key -> key in [:white, :black] end),
      do: {:ok},
      else: {:error}
  end

  def validate_pos({row, col}) do
    if row < 0 or col < 0 or row > 7 or col > 7, do: {:error}, else: {:ok}
  end

  @doc """
  Gives a string representation of the board with
  white and black queen locations shown
  """
  @spec to_string(Queens.t()) :: String.t()
  def to_string(%Queens{white: white, black: black}), do: to_string_(white: white, black: black)

  def to_string(%Queens{white: white}),
    do: to_string_(white: white, black: {-1, -1})

  def to_string(%Queens{black: black}),
    do: to_string_(black: black, white: {-1, -1})

  def to_string_(white: nil, black: {b_row, b_col}),
    do: to_string_(white: {-1, -1}, black: {b_row, b_col})

  def to_string_(white: {w_row, w_col}, black: nil),
    do: to_string_(white: {w_row, w_col}, black: {-1, -1})

  def to_string_(white: {w_row, w_col}, black: {b_row, b_col}) do
    {new_board, _} =
      empty_board()
      |> Enum.map_reduce(0, fn row, index ->
        new_row = row

        new_row =
          if index == w_row,
            do: put_queen(new_row, w_col, "W"),
            else: new_row

        new_row =
          if index == b_row,
            do: put_queen(new_row, b_col, "B"),
            else: new_row

        {new_row, index + 1}
      end)

    Enum.join(new_board, "\n")
  end

  def put_queen(row, col, color) do
    String.slice(row, 0, col * 2) <>
      color <> String.slice(row, col * 2 + 1, 15 - col * 2)
  end

  @doc """
  Checks if the queens can attack each other
  """
  @spec can_attack?(Queens.t()) :: boolean
  def can_attack?(%Queens{white: {w_row, w_col}, black: {b_row, b_col}}) do
    w_row == b_row or w_col == b_col or abs(w_row - b_row) == abs(w_col - b_col)
  end

  def can_attack?(%Queens{white: _pos}), do: false
  def can_attack?(%Queens{black: _pos}), do: false
end
