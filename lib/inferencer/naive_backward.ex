defmodule Inferencer.NaiveBackward do

  def solve(inferencer \\ Inferencer, goal) do
    case solve_all(inferencer, goal) |> Enum.take(1) do
      [] -> :unsolvable
      [ solution ] -> solution
    end
  end

  def solve_all(inferencer \\ Inferencer, goal) do
    { wmes, productions } = Inferencer.state inferencer

    for { binding, [goal_fact] } <- find_all_solutions(productions, wmes, [ goal ], %Binding{}) do
      Fact.from_condition(goal_fact, binding)
    end
  end

  defp find_all_solutions(productions, wmes, [ goal ], binding) do
    Stream.concat(
      find_in_memory(goal, wmes, binding),
      try_new_solutions(productions, wmes, goal, binding)
    )
  end

  defp find_all_solutions(productions, wmes, [ goal | goals ], binding) do
    Stream.flat_map(find_all_solutions(productions, wmes, goals, binding), fn { new_binding, goal_facts } ->
      wmes = Enum.concat(wmes, goal_facts)
      Stream.concat(
        find_in_memory(goal, wmes, new_binding),
        try_new_solutions(productions, wmes, goal, new_binding)
      )
    end)
  end

  defp try_new_solutions(productions, wmes, goal, binding, conflict_set \\ %HashSet{}) do
    new_conflicts = productions
      |> Stream.flat_map(fn production -> Production.matchings_rhs(production, [ goal ]) end)
      |> Stream.reject(fn production -> Set.member?(conflict_set, production) end)

    case new_conflicts |> Enum.take(1) do
      [] -> []
      [ head ] ->
        { production, new_goals , [ goal_fact ] } = head
        Stream.concat(
          Stream.flat_map(find_all_solutions(productions, wmes, new_goals, binding), fn { new_binding, _goal_facts } ->
            for target_fact <- production.rhs,
              new_binding = Condition.bind(target_fact, goal_fact, new_binding),
              new_binding != :unboundable do
              { new_binding, [ Condition.restrict(goal_fact, new_binding) ] }
            end
          end),
          try_new_solutions(productions, wmes, goal, binding, Set.put(conflict_set, head))
        )
    end
  end

  defp find_in_memory(goal, wmes, binding) do
    for { new_binding, goal_fact } <- Condition.filter(goal, wmes, binding) do
      { new_binding, [ goal_fact ] }
    end
  end
end
