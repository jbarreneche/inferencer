defmodule Fact do
  defstruct entity: :self, attribute: :identity, value: :self

  def new(entity \\ :self, attribute \\ :value, value) do
    %Fact{entity: entity, attribute: attribute, value: value}
  end

end
