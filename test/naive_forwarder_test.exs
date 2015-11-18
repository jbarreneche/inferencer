defmodule NaiveForwardTest do
  use ExUnit.Case
  doctest Inferencer.NaiveForward

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

    {:ok, [pid: pid]}
  end

  test "Solves already defined facts", _context do
    solution = Inferencer.NaiveForward.solve(Condition.build_constant(:p))
    assert solution == Fact.new(:p)
  end

  test "Solves derived facts", _context do
    solution = Inferencer.NaiveForward.solve(Condition.build_constant(:v))
    assert solution == Fact.new(:v)
  end

  test "Finds unsolvable conditions", _context do
    solution = Inferencer.NaiveForward.solve(Condition.build_constant(:m))
    assert solution == :unsolvable
  end

end
