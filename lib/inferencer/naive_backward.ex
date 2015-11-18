defmodule Inferencer.NaiveBackward do
  require IEx

  def solve(inferencer \\ Inferencer, goal) do
    { wmes, productions } = Inferencer.state inferencer
    case goal_met?(goal, productions, wmes, %{}) do
      nil -> try_new_solutions(productions, wmes, goal)
      { _binding, fact } -> fact
    end
  end

  defp try_new_solutions(productions, wmes, goal, current_binding \\ %{}, conflict_set \\ %HashSet{}) do
    new_conflicts = productions
      |> Enum.flat_map(fn production -> Production.matchings_rhs(production, [ goal ], current_binding) end)
      |> Enum.into(%HashSet{}) |> Set.difference(conflict_set) |> Set.to_list

    case new_conflicts do
      [] -> :unsolvable
      [ { production, binding } | _ ] ->
        case goals_met?(production.lhs, productions, wmes, binding) do
          nil -> try_new_solutions(productions, wmes, goal, current_binding, Set.put(conflict_set, { production, binding }))
          { new_binding, _fact } -> { new_binding, Fact.from_condition(goal, new_binding) }
        end
    end
  end

  defp goals_met?([], _productions, _wmes, _binding) do
    nil
  end

  defp goals_met?([ goal ], productions, wmes, binding) do
    goal_met?(goal, productions, wmes, binding)
  end

  defp goals_met?([goal | goals], productions, wmes, binding) do
    case goal_met?(goal, productions, wmes, binding) do
      nil -> nil
      { new_binding, fact } -> goals_met?(goals, productions, Set.put(wmes, fact), new_binding)
    end
  end

  defp goal_met?(goal, productions, wmes, binding) do
    case search_wme(goal, wmes, binding) do
      nil -> nil
        case try_new_solutions(productions, wmes, goal, binding) do
          :unsolvable -> nil
          { new_binding, fact } -> { new_binding, fact }
        end
      { new_binding, fact } -> { new_binding, fact }
    end
  end

  defp search_wme(goal, wmes, binding) do
    Enum.find_value(wmes, fn fact ->
      case Condition.bind(goal, fact, binding) do
        :unboundable -> nil
        new_binding  -> { new_binding, fact }
      end
    end)
  end

end
