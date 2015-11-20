defmodule NaiveBackwardTest do
  use ExUnit.Case
  doctest Inferencer.NaiveBackward

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
    solution = Inferencer.NaiveBackward.solve(Condition.build("p"))
    assert solution == Fact.new("p")
  end

  test "Solves direct derived facts" do
    solution = Inferencer.NaiveBackward.solve(Condition.build("s"))
    assert solution == Fact.new("s")
  end

  test "Solves indirect derived facts" do
    solution = Inferencer.NaiveBackward.solve(Condition.build("v"))
    assert solution == Fact.new("v")
  end

  test "Detects unsolvable conditions" do
    solution = Inferencer.NaiveBackward.solve(Condition.build("m"))
    assert solution == :unsolvable
  end

  test "Handles variables capture" do
    solution = Inferencer.NaiveBackward.solve(Condition.build(:Entity, :Attribute, "v"))
    assert solution.entity     == "self"
    assert solution.attribute  == "value"
  end

  test "Complex rules" do
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build(:X, "croacks"), Condition.build(:X, "eats", "flies") ],
      rhs: [ Condition.build(:X, "is_a", "frog") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build(:X, "chrips"), Condition.build(:X, "sings") ],
      rhs: [ Condition.build(:X, "is_a", "canary") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build(:X, "is_a", "canary") ],
      rhs: [ Condition.build(:X, "color", "yellow") ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build(:X, "is_a", "frog") ],
      rhs: [ Condition.build(:X, "color", "green") ]
    })
    Inferencer.assert(Condition.build("Fritz", "croacks"))
    Inferencer.assert(Condition.build("Fritz", "eats", "flies"))

    solution = Inferencer.NaiveBackward.solve(Condition.build(:T, "color", "green"))
    assert solution.entity == "Fritz"
    assert solution.value == "green"
  end

end
