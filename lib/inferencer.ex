defmodule Inferencer do
  defstruct working_memory: %HashSet{}, productions: []

  def start_link(name \\ __MODULE__) do
    Agent.start_link(fn -> %Inferencer{} end, name: name)
  end

  def reset(inferencer \\ __MODULE__) do
    Agent.update(inferencer, fn _ -> %Inferencer{} end)
  end

  def assert(inferencer \\ __MODULE__,  new_fact) do
    Agent.update(inferencer, &prepend_to_memory(&1, new_fact))
  end

  def add_rule(inferencer \\ __MODULE__, new_production) do
    Agent.update(inferencer, &prepend_to_productions(&1, new_production))
  end

  def state(inferencer \\ __MODULE__) do
    Agent.get(inferencer, &({&1.working_memory, &1.productions}))
  end

  def working_memory(inferencer \\ __MODULE__) do
    Agent.get(inferencer, &(&1.working_memory))
  end

  def productions(inferencer \\ __MODULE__) do
    Agent.get(inferencer, &(&1.productions))
  end

  defp prepend_to_memory(inferencer, fact) do
    %Inferencer{ inferencer | working_memory: Set.put(inferencer.working_memory, fact) }
  end

  defp prepend_to_productions(inferencer, production) do
    %Inferencer{ inferencer | productions: [ production | inferencer.productions ] }
  end

end
