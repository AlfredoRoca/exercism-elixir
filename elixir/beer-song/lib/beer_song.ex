defmodule BeerSong do
  @doc """
  Get a single verse of the beer song
  """
  @spec verse(integer) :: String.t()
  def verse(0) do
    """
    No more bottles of beer on the wall, no more bottles of beer.
    Go to the store and buy some more, 99 bottles of beer on the wall.
    """
  end

  def verse(1) do
    """
    1 bottle of beer on the wall, 1 bottle of beer.
    Take it down and pass it around, no more bottles of beer on the wall.
    """
  end

  def verse(number) do
    """
    #{bottles(number)} of beer on the wall, #{bottles(number)} of beer.
    Take one down and pass it around, #{bottles(number - 1)} of beer on the wall.
    """
  end

  def bottles(1), do: "1 bottle"
  def bottles(number), do: "#{number} bottles"

  @doc """
  Get the entire beer song for a given range of numbers of bottles.
  """
  @spec lyrics(Range.t()) :: String.t()
  def lyrics(range \\ 99..0) do
    Enum.map(range, &verse/1)
    |> Enum.join("\n")
  end
end
