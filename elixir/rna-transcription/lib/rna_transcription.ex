defmodule RnaTranscription do
  @doc """
  Transcribes a character list representing DNA nucleotides to RNA

  ## Examples

  iex> RnaTranscription.to_rna('ACTG')
  'UGAC'
  """
  @spec to_rna([char]) :: [char]
  def transcribe(?G), do: ?C
  def transcribe(?C), do: ?G
  def transcribe(?T), do: ?A
  def transcribe(?A), do: ?U

  def to_rna(dna) do
    Enum.map(dna, &transcribe(&1))
  end
end
