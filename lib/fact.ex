defmodule Fact do
  defstruct entity: "self", attribute: "identity", value: "self"

  def new(entity \\ "self", attribute \\ "value", value) do
    %Fact{entity: entity, attribute: attribute, value: value}
  end

  def from_condition(condition, binding) do
    {:ok, entity}    = Binding.get(binding, condition.entity)
    {:ok, attribute} = Binding.get(binding, condition.attribute)
    {:ok, value}     = Binding.get(binding, condition.value)

    new( entity, attribute, value )
  end

end
