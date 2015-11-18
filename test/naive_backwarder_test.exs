defmodule NaiveBackwardTest do
  use ExUnit.Case
  doctest Inferencer.NaiveBackward

  setup do
    {:ok, pid } = Inferencer.start_link

    Inferencer.assert(Fact.new(:p))
    Inferencer.assert(Fact.new(:q))
    Inferencer.assert(Fact.new(:r))
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build_constant(:p), Condition.build_constant(:q) ],
      rhs: [ Fact.new(:s) ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build_constant(:r) ],
      rhs: [ Fact.new(:t) ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build_constant(:s), Condition.build_constant(:t) ],
      rhs: [ Fact.new(:u) ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build_constant(:s), Condition.build_constant(:r) ],
      rhs: [ Fact.new(:v) ]
    })
    Inferencer.add_rule(%Production{
      lhs: [ Condition.build_constant(:w) ],
      rhs: [ Fact.new(:m) ]
    })

    {:ok, [pid: pid]}
  end

  test "Solves already defined facts" do
    solution = Inferencer.NaiveBackward.solve(Condition.build_constant(:p))
    assert solution == Fact.new(:p)
  end

  test "Solves direct derived facts" do
    solution = Inferencer.NaiveBackward.solve(Condition.build_constant(:s))
    assert solution == Fact.new(:s)
  end

  test "Solves indirect derived facts" do
    solution = Inferencer.NaiveBackward.solve(Condition.build_constant(:v))
    assert solution == Fact.new(:v)
  end

  test "Detects unsolvable conditions" do
    solution = Inferencer.NaiveBackward.solve(Condition.build_constant(:m))
    assert solution == :unsolvable
  end

end
