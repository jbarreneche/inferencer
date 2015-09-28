defmodule Inferencer.NaiveForward do

  def solve(inferencer \\ Inferencer, goal) do
    { wmes, productions } = Inferencer.state inferencer
    case goal_met?(goal, wmes) do
      nil  -> try_new_solutions(productions, wmes, goal)
      fact -> fact
    end
  end

  defp try_new_solutions(productions, wmes, goal, conflict_set \\ %HashSet{}) do
    new_conflicts =
      Enum.flat_map(productions, fn production -> Production.matchings(production, wmes) end)
      |> Enum.into(%HashSet{}) |> Set.difference(conflict_set) |> Set.to_list

    case new_conflicts do
      [] -> :unsolvable
      [ { production, token } | _ ] ->
        case goal_met?(goal, production.rhs) do
          nil  -> try_new_solutions(productions, Enum.concat(production.rhs, wmes), goal, Set.put(conflict_set, { production, token }))
          fact -> fact
        end
    end
  end

  defp goal_met?(goal, wmes) do
    Enum.find_value(wmes, fn fact ->
      case Condition.bind(goal, fact) do
        :unboundable -> nil
        _binding     -> fact
      end
    end)
  end
end
