defmodule Production do
  defstruct name: "empty", lhs: [], rhs: []
  require IEx

  def matchings_lhs(production, goals, binding \\ %Binding{}) do
    for { binding, _token } <- find_all_matchings(production.lhs, goals, binding) do
      {
        production,
        Enum.map(production.rhs, fn c -> Condition.restrict(c, binding) end)
      }
    end
  end

  def matchings_rhs(production, goals) do
    for { binding, token } <- find_all_matchings(goals, production.rhs, %Binding{}) do
      {
        production,
        Enum.map(production.lhs, fn c -> Condition.restrict(c, binding) end),
        token
      }
    end
  end

  defp find_all_matchings([], _facts, _binding), do: []

  defp find_all_matchings([ condition ], facts, binding) do
    for { new_binding, matched_condition } <- Condition.filter(condition, facts, binding) do
      { new_binding, [ matched_condition ] }
    end
  end

  defp find_all_matchings([ condition | lhs ], facts, binding) do
    for { new_binding, matched_condition } <- Condition.filter(condition, facts, binding),
      { final_binding, matched_lhs } <- find_all_matchings(lhs, facts, new_binding) do
      { final_binding, [ matched_condition | matched_lhs ]}
    end
  end

end
