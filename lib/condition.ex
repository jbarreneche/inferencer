defmodule Condition do
  defstruct entity: {:constant, :self}, attribute: {:constant, :identity}, value: {:constant, :self}

  def build_constant(entity \\ :self, attribute \\ :value, value) do
    %Condition{
      entity: {:constant, entity}, attribute: {:constant, attribute}, value: {:constant, value}
    }
  end

  def bind(condition, fact, binding \\ %{}) do
    binding |>
      match_part(condition.entity, fact.entity) |>
      match_part(condition.attribute, fact.attribute) |>
      match_part(condition.value, fact.value)
  end

  defp match_part(:unboundable, _variable, _value), do: :unboundable
  defp match_part(binding, {:constant, value}, value), do: binding
  defp match_part(_binding, {:constant, _expected}, _value), do: :unboundable

  defp match_part(binding, {:variable, name}, value) do
    case Dict.get(binding, name) do
      nil    -> Dict.put(binding, name, value)
      ^value -> binding
      _      -> :unboundable
    end
  end

end
