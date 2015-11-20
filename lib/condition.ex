defmodule Condition do
  defstruct entity: {:constant, "self"}, attribute: {:constant, "identity"}, value: {:constant, "self"}

  def build(entity \\ "self", attribute \\ "value", value) do
    %Condition{
      entity: wrap(entity), attribute: wrap(attribute), value: wrap(value)
    }
  end

  def filter(condition, conditions, binding) do
    aliased_condition = isolate_variables(condition)
    Stream.flat_map(conditions, fn rcondition ->
      case bind(aliased_condition, rcondition, binding) do
        :unboundable -> []
        new_binding  -> [{ new_binding, aliased_condition }]
      end
    end)
  end

  # Rename to unify
  def bind(lcondition, rcondition, binding \\ %Binding{}) do
    binding
      |> Binding.unify(lcondition.entity,    rcondition.entity)
      |> Binding.unify(lcondition.attribute, rcondition.attribute)
      |> Binding.unify(lcondition.value,     rcondition.value)
  end

  def restrict(condition, binding) do
    %Condition{
      entity:    unbind_field(condition.entity, binding),
      attribute: unbind_field(condition.attribute, binding),
      value:     unbind_field(condition.value, binding)
    }
  end

  defp isolate_variables(condition) do
    %Condition{
      entity:    alias_field(condition.entity),
      attribute: alias_field(condition.attribute),
      value:     alias_field(condition.value)
    }
  end

  defp unbind_field(field, binding) do
    case Binding.get(binding, field) do
      {:ok, value} -> {:constant, value}
      :error       -> {:variable, field}
    end
  end

  defp wrap(value) when is_atom(value) do
    {:variable, value}
  end

  defp wrap(value) do
    {:constant, value}
  end

  defp alias_field({:constant, value}), do: {:constant, value}
  defp alias_field({:variable, name}) do
    {:variable, Atom.to_char_list(name)}
  end

end
