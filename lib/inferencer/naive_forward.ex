defmodule Inferencer.NaiveForward do

  def solve(inferencer \\ Inferencer, goal) do
    { wmes, productions } = Inferencer.state inferencer
    case goal_met?(goal, wmes) do
      nil  -> try_new_solutions(productions, wmes, goal)
      { binding, _fact } -> Fact.from_condition(goal, binding)
    end
  end

  defp try_new_solutions(productions, wmes, goal, conflict_set \\ %HashSet{}) do
    new_conflicts = productions
      |> Stream.flat_map(fn production -> Production.matchings_lhs(production, wmes) end)
      |> Stream.reject(fn production -> Set.member?(conflict_set, production) end)

    case new_conflicts |> Enum.take(1) do
      [] -> :unsolvable
      [ head ] ->
        { _production, new_facts } = head
        case goal_met?(goal, new_facts) do
          nil  -> try_new_solutions(productions, Enum.concat(new_facts, wmes), goal, Set.put(conflict_set, head))
          { binding, _fact } -> Fact.from_condition(goal, binding)
        end
    end
  end

  defp goal_met?(goal, wmes) do
    Enum.find_value(wmes, fn fact ->
      case Condition.bind(goal, fact) do
        :unboundable -> nil
        binding     -> { binding, fact }
      end
    end)
  end
end
