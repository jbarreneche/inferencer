defmodule NaiveForwardTest do
  use ExUnit.Case
  doctest Inferencer.NaiveForward

  setup do
    {:ok, pid } = Inferencer.start_link

    Inferencer.assert(Condition.build("p"))
    Inferencer.assert(Condition.build("q"))
    Inferencer.assert(Condition.build("r"))
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build("p"), Condition.build("q") ],
      rhs: [ Condition.build("s") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build("r") ],
      rhs: [ Condition.build("t") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build("s"), Condition.build("t") ],
      rhs: [ Condition.build("u") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build("s"), Condition.build("r") ],
      rhs: [ Condition.build("v") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build("w") ],
      rhs: [ Condition.build("m") ]
    })

    {:ok, [pid: pid]}
  end

  test "Solves already defined facts" do
    solution = Inferencer.NaiveForward.solve(Condition.build("p"))
    assert solution == Fact.new("p")
  end

  test "Solves derived facts" do
    solution = Inferencer.NaiveForward.solve(Condition.build("v"))
    assert solution == Fact.new("v")
  end

  test "Detects unsolvable conditions" do
    solution = Inferencer.NaiveForward.solve(Condition.build("m"))
    assert solution == :unsolvable
  end

  @tag timeout: 1_000_000
  test "Complex rules" do
    Inferencer.reset
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build(:X, "croacks"), Condition.build(:X, "eats", "flies") ],
      rhs: [ Condition.build(:X, "is_a", "frog") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build(:X, "chrips"), Condition.build(:X, "sings") ],
      rhs: [ Condition.build(:X, "is_a", "canary") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build(:X, "is_a", "frog") ],
      rhs: [ Condition.build(:X, "color", "green") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build(:X, "is_a", "canary") ],
      rhs: [ Condition.build(:X, "color", "yellow") ]
    })
    Inferencer.assert(Condition.build("Fritz", "croacks"))
    Inferencer.assert(Condition.build("Fritz", "eats", "flies"))

    solution = Inferencer.NaiveForward.solve(Condition.build("Fritz", "color", :X))
    assert solution.value == "green"
  end

end
