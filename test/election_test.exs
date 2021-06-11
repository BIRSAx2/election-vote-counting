defmodule ElectionTest do
  use ExUnit.Case
  doctest Election

  #  runs before each test call
  setup do
    %{election: %Election{}}
  end

  test "Updating election name from a command", ctx do
    # testing: arrange |> act |> assert

    command = "name Mouhieddine Sabir"

    election = Election.update(ctx.election, command)

    assert election == %Election{name: "Mouhieddine Sabir"}
  end

  test "adding a new candidate from a command", ctx do
    command = "add Mouhieddine Sabir"

    election = Election.update(ctx.election, command)

    assert election == %Election{candidates: [Candidate.new(1, "Mouhieddine Sabir")], next_id: 2}
  end

  test "voting for a candidate from a command", ctx do
    add_candidate = "add Mouhieddine Sabir"
    vote_candidate = "vote 1"

    election = Election.update(ctx.election, add_candidate) |> Election.update(vote_candidate)

    assert election == %Election{
             candidates: [%Candidate{id: 1, name: "Mouhieddine Sabir", votes: 1}],
             next_id: 2
           }
  end

  test "quitting the app", ctx do
    quit_command = "quit"

    election = Election.update(ctx.election, quit_command)

    assert election = :quit
  end
end
