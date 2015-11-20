defmodule Condition do
  defstruct entity: {:constant, "self"}, attribute: {:constant, "identity"}, value: {:constant, "self"}

  def build(entity \\ "self", attribute \\ "value", value) do
    %Condition{
      entity: wrap(entity), attribute: wrap(attribute), value: wrap(value)
    }
  end

  # Rename to unify
  def bind(lcondition, rcondition, binding \\ %Binding{}) do
    binding
      |> Binding.unify(lcondition.entity,    rcondition.entity)
      |> Binding.unify(lcondition.attribute, rcondition.attribute)
      |> Binding.unify(lcondition.value,     rcondition.value)
  end

  def restrict(condition, binding) do
    {:ok, entity}    = Binding.get(binding, condition.entity)
    {:ok, attribute} = Binding.get(binding, condition.attribute)
    {:ok, value}     = Binding.get(binding, condition.value)

    build( entity, attribute, value )
  end


  defp wrap(value) when is_atom(value) do
    {:variable, value}
  end

  defp wrap(value) do
    {:constant, value}
  end

end
