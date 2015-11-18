defmodule Production do
  defstruct name: "empty", lhs: [], rhs: []

  def matchings_lhs(production, facts) do
    for { _binding, token } <- find_all_matchings(production.lhs, facts, %{}) do
      { production, token }
    end
  end

  def matchings_rhs(production, goals, binding \\ %{}) do
    for { binding, token } <- find_all_matchings(goals, production.rhs, binding) do
      { production, binding }
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
