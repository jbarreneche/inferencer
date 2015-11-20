defmodule Production do
  defstruct name: "empty", lhs: [], rhs: []

  def matchings_lhs(production, goals) do
    for { binding, _token } <- find_all_matchings(production.lhs, goals, %Binding{}) do
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
        Enum.map(goals, fn c -> Condition.restrict(c, binding) end)
      }
    end
  end

  defp find_all_matchings([], _facts, _binding), do: []

  defp find_all_matchings([ condition ], facts, binding) do
    for fact <- facts,
        binding = Condition.bind(condition, fact, binding),
        binding != :unboundable, do: { binding, [ fact ] }
  end

  defp find_all_matchings([ condition | lhs ], facts, binding) do
    for fact <- facts,
        binding = Condition.bind(condition, fact, binding),
        binding != :unboundable,
        { binding, token } <- find_all_matchings(lhs, facts, binding) do
      { binding, [ fact | token ] }
    end
  end

end
