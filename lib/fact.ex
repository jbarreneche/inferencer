defmodule Fact do
  defstruct entity: :self, attribute: :identity, value: :self

  def new(entity \\ :self, attribute \\ :value, value) do
    %Fact{entity: entity, attribute: attribute, value: value}
  end

  def from_condition(condition, binding) do
    new(
      extract(condition.entity, binding),
      extract(condition.attribute, binding),
      extract(condition.value, binding)
    )
  end

  defp extract({:constant, value}, _binding) do
    value
  end

  defp extract({:variable, name}, binding) do
    {:ok, value} = Dict.fetch(binding, name)
    value
  end

end
