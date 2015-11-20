defmodule Inferencer.NaiveForward do

  def solve(inferencer \\ Inferencer, goal) do
    case solve_all(inferencer, goal) |> Enum.take(1) do
      [] -> :unsolvable
      [ solution ] -> solution
    end
  end

  def solve_all(inferencer \\ Inferencer, goal) do
    { wmes, productions } = Inferencer.state(inferencer)
    goal = Condition.from_tuple(goal)

    Stream.concat(
      find_in_memory(goal, wmes),
      try_new_solutions(productions, wmes, goal)
    )
  end

  defp try_new_solutions(productions, wmes, goal, conflict_set \\ %HashSet{}) do
    new_conflicts = productions
      |> Stream.flat_map(fn production -> Production.matchings_lhs(production, wmes) end)
      |> Stream.reject(fn production -> Set.member?(conflict_set, production) end)

    case new_conflicts |> Enum.take(1) do
      [
        { production, new_facts }
      ] ->
        Stream.concat(
          find_in_memory(goal, new_facts),
          try_new_solutions(productions, Enum.concat(new_facts, wmes), goal, Set.put(conflict_set, { production, new_facts }))
        )
      [] -> []
    end
  end

  defp find_in_memory(goal, wmes) do
    for { binding, goal_fact } <- Condition.filter(goal, wmes, %Binding{}) do
      Fact.from_condition(goal_fact, binding)
    end
  end
end
