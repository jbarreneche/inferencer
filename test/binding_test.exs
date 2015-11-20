defmodule BindingTest do
  use ExUnit.Case
  doctest Binding

  test "Direct memory" do
    binding = %Binding{}
    binding = Binding.unify(binding, {:variable, :A}, {:variable, :B})
    binding = Binding.unify(binding, {:variable, :B}, {:variable, :C})
    binding = Binding.set(binding, {:variable, :B}, 4)

    assert Binding.get(binding, {:variable, :C}) == {:ok, 4}
    assert Binding.get(binding, {:variable, :A}) == {:ok, 4}
  end
end
