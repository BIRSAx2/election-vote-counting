defmodule Election do
  defstruct(
    name: "",
    candidates: [],
    next_id: 1
  )

  def run do
    %Election{} |> run()
  end

  def run(:quit), do: :quit

  # side effects
  def run(election = %Election{}) do
    [IO.ANSI.clear(), IO.ANSI.cursor(0, 0)] |> IO.write()

    election
    |> view
    |> IO.write()

    command = IO.gets(">")

    election
    |> update(command)
    |> run()
  end

  def update(_election, ["q" <> _]), do: :quit

  @doc """
  Updates Election Struc based on provided command

  ## Prarameters

  - election: Election Struct
  - command: String based command. Each command can be shortend to what's shown in parenthesis
    - (n)ame command update the election name
      - example: "n Mayor"
    - (a)dd command adds a new candidate
      - example: "a Mouhieddine Sabir"
    - (v)ote command increments the vote count for candidate
      - example: "v 1"
    - (q)uit command returns and atom
      - example: "q"

  Returns `Ekection` struct

  ## Examples

  iex> %Election{} |> Election.update("n Mayor")
  %Election{name: "Mayor"}

  """
  def update(election, command) when is_binary(command) do
    update(election, String.split(command))
  end

  def update(election, ["n" <> _ | args]) do
    name = Enum.join(args, " ")
    Map.put(election, :name, name)
  end

  def update(election, ["a" <> _ | args]) do
    name = Enum.join(args, " ")
    candidate = Candidate.new(election.next_id, name)
    candidates = [candidate | election.candidates]

    # election
    # |> Map.put(:candidates, candidates)
    # |> Map.put(:next_id, election.next_id + 1)

    %{election | candidates: candidates, next_id: election.next_id + 1}
  end

  def update(election, ["v" <> _, id]) do
    vote(election, Integer.parse(id))
  end

  defp vote(election, {id, ""}) do
    candidates = Enum.map(election.candidates, &inc_vote_by_id(&1, id))
    Map.put(election, :candidates, candidates)
  end

  defp vote(election, _errors), do: election

  defp inc_vote_by_id(candidate, id) when is_integer(id) do
    inc_vote_by_id(candidate, candidate.id == id)
  end

  defp inc_vote_by_id(candidate, _inc_vote = false), do: candidate

  defp inc_vote_by_id(candidate, _inc_vote = true) do
    Map.update!(candidate, :votes, &(&1 + 1))
  end

  def view(election) do
    # This is an IO List
    [view_header(election), view_body(election), view_footer()]
  end

  def view_header(election) do
    #
    [
      "Election for: #{election.name}\n"
    ]
  end

  def view_footer() do
    [
      "\n",
      "commands: (n)ame <election>, (a)dd <candidate>, (v)ote <id>, (q)uit\n"
    ]
  end

  def view_body(election) do
    election.candidates
    |> sort_candidates_by_votes_desc()
    |> candidates_to_strings()
    |> prepend_candidates_header()
  end

  defp prepend_candidates_header(candidates) do
    [
      "id\tvotes\tname\n",
      "-----------------------------\n"
      | candidates
    ]
  end

  defp candidates_to_strings(candidates) do
    candidates
    |> Enum.map(fn %{id: id, name: name, votes: votes} ->
      "#{id}\t#{votes}\t#{name}\n"
    end)
  end

  defp sort_candidates_by_votes_desc(candidates) do
    candidates
    |> Enum.sort(&(&1.votes >= &2.votes))
  end
end
