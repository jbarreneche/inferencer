defmodule NaiveForwardTest do
  use ExUnit.Case
  doctest Inferencer.NaiveForward

  setup do
    {:ok, pid } = Inferencer.start_link

    Inferencer.assert({"p"})
    Inferencer.assert({"q"})
    Inferencer.assert({"r"})
    Inferencer.add_rule(
      [ {"p"}, {"q"} ],
      [ {"s"} ]
    )
    Inferencer.add_rule(
      [ {"r"} ],
      [ {"t"} ]
    )
    Inferencer.add_rule(
      [ {"s"}, {"t"} ],
      [ {"u"} ]
    )
    Inferencer.add_rule(
      [ {"s"}, {"r"} ],
      [ {"v"} ]
    )
    Inferencer.add_rule(
      [ {"w"} ],
      [ {"m"} ]
    )

    {:ok, [pid: pid]}
  end

  test "Solves already defined facts" do
    solution = Inferencer.NaiveForward.solve({"p"})
    assert solution == Fact.new("p")
  end

  test "Solves derived facts" do
    solution = Inferencer.NaiveForward.solve({"v"})
    assert solution == Fact.new("v")
  end

  test "Detects unsolvable conditions" do
    solution = Inferencer.NaiveForward.solve({"m"})
    assert solution == :unsolvable
  end

  test "Complex rules" do
    Inferencer.add_rule(
      [ {:X, "croacks"}, {:X, "eats", "flies"} ],
      [ {:X, "is_a", "frog"} ]
    )
    Inferencer.add_rule(
      [ {:X, "chrips"}, {:X, "sings"} ],
      [ {:X, "is_a", "canary"} ]
    )
    Inferencer.add_rule(
      [ {:X, "is_a", "frog"} ],
      [ {:X, "color", "green"} ]
    )
    Inferencer.add_rule(
      [ {:X, "is_a", "canary"} ],
      [ {:X, "color", "yellow"} ]
    )
    Inferencer.assert({"Fritz", "croacks"})
    Inferencer.assert({"Fritz", "eats", "flies"})

    solution = Inferencer.NaiveForward.solve({"Fritz", "color", :X})
    assert solution.value == "green"
  end

end
