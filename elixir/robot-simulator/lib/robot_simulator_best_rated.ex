defmodule RobotSimulator2 do
  # Robot Creation

  def create(direction \\ :north, position \\ {0, 0}) do
    with :ok <- validate_position(position),
         :ok <- validate_direction(direction),
         do: %{position: position, direction: direction}
  end

  defp validate_position({x, y} = position) when is_integer(x) and is_integer(y), do: :ok
  defp validate_position(_), do: {:error, "invalid position"}

  defp validate_direction(direction) when direction in [:north, :south, :east, :west], do: :ok
  defp validate_direction(_), do: {:error, "invalid direction"}

  # Robot Access

  def direction(robot), do: robot.direction

  def position(robot), do: robot.position

  # Simulation

  def simulate(robot, instructions) do
    instructions
    |> String.graphemes()
    |> Enum.reduce(robot, &move(&2, &1))
  end

  defp move(%{position: {x, y}, direction: :north} = robot, "A"),
    do: %{robot | position: {x, y + 1}}

  defp move(%{position: {x, y}, direction: :south} = robot, "A"),
    do: %{robot | position: {x, y - 1}}

  defp move(%{position: {x, y}, direction: :east} = robot, "A"),
    do: %{robot | position: {x + 1, y}}

  defp move(%{position: {x, y}, direction: :west} = robot, "A"),
    do: %{robot | position: {x - 1, y}}

  defp move(%{direction: :north} = robot, "L"), do: %{robot | direction: :west}
  defp move(%{direction: :south} = robot, "L"), do: %{robot | direction: :east}
  defp move(%{direction: :east} = robot, "L"), do: %{robot | direction: :north}
  defp move(%{direction: :west} = robot, "L"), do: %{robot | direction: :south}

  defp move(%{direction: :north} = robot, "R"), do: %{robot | direction: :east}
  defp move(%{direction: :south} = robot, "R"), do: %{robot | direction: :west}
  defp move(%{direction: :east} = robot, "R"), do: %{robot | direction: :south}
  defp move(%{direction: :west} = robot, "R"), do: %{robot | direction: :north}

  defp move(_, _), do: {:error, "invalid instruction"}
end
