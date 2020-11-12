defmodule Tournament do
  @doc """
  Given `input` lines representing two teams and whether the first of them won,
  lost, or reached a draw, separated by semicolons, calculate the statistics
  for each team's number of games played, won, drawn, lost, and total points
  for the season, and return a nicely-formatted string table.

  A win earns a team 3 points, a draw earns 1 point, and a loss earns nothing.

  Order the outcome by most total points for the season, and settle ties by
  listing the teams in alphabetical order.
  """

  alias Tournament.TeamRecord

  defmodule TeamRecord do
    defstruct name: "", mp: 0, w: 0, d: 0, l: 0
  end

  @spec tally(input :: list(String.t())) :: String.t()
  def tally(input) do
    {_, score_table} =
      input
      |> Enum.map_reduce(%{}, fn line, score_table -> {line, score_table} = parse_line(line, score_table)
    {line, score_table} end)

    score_table
    # |> Enum.sort()
  end

  def parse_line(line, score_table) do
    [team1, team2, result] = String.split(line, ";")

    {team1_record, score_table} = get_team_record_and_update_score_table(team1, score_table)
    {team2_record, score_table} = get_team_record_and_update_score_table(team2, score_table)

    team1_record = annotate_team(team1_record, result)
    team2_record = annotate_team(team2_record, inverted_result(result))

    score_table =
      Map.merge(score_table, team1_record)
      |> Map.merge(team2_record)

    {line, score_table}
  end

  def annotate_team(%TeamRecord{name: team, mp: mp, w: w, d: d, l: l}, result) do
    w = if(result == "win", do: w + 1, else: w)
    d = if(result == "draw", do: d + 1, else: d)
    l = if(result == "loss", do: l + 1, else: l)
    %TeamRecord{name: team, mp: mp + 1, w: w, d: d, l: l}
  end

  def inverted_result(result) when result == "win", do: "loss"
  def inverted_result(result) when result == "loss", do: "win"
  def inverted_result(result) when result == "draw", do: "draw"

  def get_team_record_and_update_score_table(team, score_table) do
    case Map.fetch(score_table, team) do
      {:ok, team_record} ->
        {team_record, score_table}

      :error ->
        tr = %TeamRecord{name: team}
        {tr, Map.put_new(score_table, team, tr)}
    end
  end
end
