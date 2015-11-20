defmodule Inferencer.NaiveBackward do

  def solve(inferencer \\ Inferencer, goal) do
    { wmes, productions } = Inferencer.state inferencer
    case search_wme(goal, wmes, %Binding{}) do
      nil ->
        case try_new_solutions(productions, wmes, goal) do
          :unsolvable -> :unsolvable
          { _binding, [ goal_fact ] } -> Fact.from_condition(goal_fact, %Binding{})
        end
      { new_binding, _fact } -> Fact.from_condition(goal, new_binding)
    end
  end

  defp try_new_solutions(productions, wmes, goal, conflict_set \\ %HashSet{}) do
    new_conflicts = productions
      |> Stream.flat_map(fn production -> Production.matchings_rhs(production, [goal]) end)
      |> Stream.reject(fn production -> Set.member?(conflict_set, production) end)

    case new_conflicts |> Enum.take(1) do
      [] -> :unsolvable
      [ head | _ ] ->
        { production, new_goals , [ goal_fact ] } = head
        case goals_met?(new_goals, productions, wmes) do
          :unsolvable -> try_new_solutions(productions, wmes, goal, Set.put(conflict_set, head))
          { new_binding, _facts } -> { new_binding, [ goal_fact ] }
        end
    end
  end

  defp goals_met?(goals, productions, wmes) do
    goals_met?(goals, productions, wmes, %Binding{})
  end

  defp goals_met?([ goal ], productions, wmes, binding) do
    case search_wme(goal, wmes, binding) do
      nil -> try_new_solutions(productions, wmes, goal)
      { new_binding, fact } -> { new_binding, [ fact ] }
    end
  end

  defp goals_met?([goal | goals], productions, wmes, binding) do
    case goals_met?(goals, productions, wmes, binding) do
      :unsolvable -> :unsolvable
      { new_binding, facts } ->
        case goals_met?([ goal ], productions, Enum.concat(facts, wmes), new_binding) do
          :unsolvable -> :unsolvable
          { new_binding, [ fact ] } -> { new_binding, [ fact | facts ]}
        end
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
