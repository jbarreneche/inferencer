defmodule Binding do
  defstruct memory: %{}, aliases: %{}

  def unify(:unboundable, _left, _right), do: :unboundable
  def unify(binding, left, right) do
    case get(binding, left) do
      :error       -> _assign(binding, left, right)
      {:ok, value} ->
        case get(binding, right) do
          {:ok, ^value} -> binding
          {:ok, _}      -> :unboundable
          :error        -> set(binding, right, value)
        end
    end
  end

  def get(_binding, {:constant, value}) do
    {:ok, value}
  end
  def get(binding, {:variable, name}) do
    Dict.fetch(binding.memory, get_alias_name(binding, name))
  end

  def set(binding, {:variable, name}, value) do
    %Binding{
      memory:  Dict.put_new(binding.memory, get_alias_name(binding, name), value),
      aliases: binding.aliases
    }
  end

  defp _assign(binding, {:variable, vleft}, right) do
    case get(binding, right) do
      :error ->
        {:variable, vright} = right
        %Binding{
          memory:  binding.memory,
          aliases: Dict.put_new(binding.aliases, get_alias_name(binding, vleft), get_alias_name(binding, vright))
        }
      {:ok, value} -> set(binding, {:variable, vleft}, value)
    end
  end

  defp get_alias_name(binding, variable) do
    case Dict.fetch(binding.aliases, variable) do
      :error -> variable
      {:ok, value} -> get_alias_name(binding, value)
    end
  end

end
