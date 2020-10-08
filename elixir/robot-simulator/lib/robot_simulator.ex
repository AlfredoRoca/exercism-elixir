defmodule RobotSimulator do
  @doc """
  Create a Robot Simulator given an initial direction and position.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """

  @valid_directions [:north, :east, :south, :west]

  @spec create(direction :: atom, position :: {integer, integer}) :: any
  def create(direction \\ :north, position \\ {0, 0})

  def create(direction, {_x, _y}) when direction not in @valid_directions do
    {:error, "invalid direction"}
  end

  def create(direction, position = {x, y}) when is_integer(x) and is_integer(y) do
    %{direction: direction, position: position}
  end

  def create(_direction, _position) do
    {:error, "invalid position"}
  end

  @doc """
  Simulate the robot's movement given a string of instructions.

  Valid instructions are: "R" (turn right), "L", (turn left), and "A" (advance)
  """
  @spec simulate(robot :: any, instructions :: String.t()) :: any
  def simulate(robot, instructions) do
    instructions_list = String.to_charlist(instructions)

    result =
      if Enum.all?(instructions_list, fn x -> x in [?A, ?R, ?L] end) do
        do_action(robot, instructions_list)
      else
        {:error, "invalid instruction"}
      end

    case result do
      {:error, _} -> result
      robot -> robot
    end
  end

  def do_action(robot, []), do: robot

  def do_action(robot, instructions_list) do
    [action | instructions_list] = instructions_list

    move(robot, action)
    |> do_action(instructions_list)
  end

  @doc """
  moves the robot 1 position in the given direction
  """
  def move(%{direction: dir, position: pos}, ?R) do
    new_dir =
      case dir do
        :north -> :east
        :east -> :south
        :south -> :west
        :west -> :north
      end

    %{direction: new_dir, position: pos}
  end

  def move(%{direction: dir, position: pos}, ?L) do
    new_dir =
      case dir do
        :north -> :west
        :west -> :south
        :south -> :east
        :east -> :north
      end

    %{direction: new_dir, position: pos}
  end

  def move(%{direction: dir, position: {x, y}}, ?A) do
    new_pos =
      case dir do
        :north -> {x, y + 1}
        :west -> {x - 1, y}
        :south -> {x, y - 1}
        :east -> {x + 1, y}
      end

    %{direction: dir, position: new_pos}
  end

  @doc """
  Return the robot's direction.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec direction(robot :: any) :: atom
  def direction(%{direction: direction}), do: direction

  @doc """
  Return the robot's position.
  """
  @spec position(robot :: any) :: {integer, integer}
  def position(%{position: position}), do: position
end
