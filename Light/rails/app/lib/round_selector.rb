class RoundSelector
  attr_reader :round_selections, :matches_configuration

  def initialize(rounds, players, board_size)
    @rounds = rounds
    @players = players
    @count_players = players.count
    @board_size = board_size
    @matches_configuration = create_matches_configuration
    @round_selections = {}
  end

  def select_all_rounds
    user_selection = []
    @rounds.times do |n|
      user_selection.push(select_round(n+1))
    end
    user_selection
  end

  private

  def generate_random(count, aval_players)
    match=[]
    match_ids=[]
    count.times do
      rand = rand(aval_players.count)
      match_ids.push(aval_players[rand][:id])
      match.push(aval_players.slice!(rand))
    end
    [match, match_ids.sort, aval_players]
  end

  def select_round(round)
    selection = []
    selection_ids = []
    aval_players = @players.dup
    if round == 1
      @matches_configuration.each do |count|
        match_selection = generate_random(count, aval_players)
        selection.push(match_selection[0])
        selection_ids.push(match_selection[1])
        aval_players = match_selection[2]
      end
    else
      @matches_configuration.each do |count|
        condition = 2
        best_repetition = Float::INFINITY
        best_selection = []

        (0..500).each do
          match_selection = generate_random(count, aval_players.dup)
          repetition = check_selection(match_selection[1])

          if repetition<best_repetition
            best_repetition = repetition
            best_selection = match_selection
          end

          if repetition<= condition
            break
          end
        end

        selection.push(best_selection[0])
        selection_ids.push(best_selection[1].sort)
        aval_players = best_selection[2]
      end
    end
    @round_selections[round] = selection_ids
    selection
  end

  def check_selection(selected_match)
    max_repetition = 0
    @round_selections.each do |_, round|
      round.each do |match|
        match_repetition = 0
        selected_match.each do |id|
          if match.include? id
            match_repetition = match_repetition + 1
          end
        end
        if match_repetition>max_repetition
          max_repetition=match_repetition
        end
      end
    end
    max_repetition
  end

  def create_matches_configuration
    configuration = []
    # Calculate the number of matches required, and then calculate if the number of players
    # fits perfectly in the number of matches, for the selected board size
    @n_matches = (@count_players / @board_size.to_f).ceil
    remainder = (@count_players / @board_size.to_f) - (@count_players / @board_size)

    # If it does, all matches have the same number of players, the board size
    if remainder == 0.0
      @n_matches.times do
        configuration.push(@board_size)
      end
    else
      # If it doesn't, calculate the number of players for the more fair configuration
      # (each match should have at most 1 player more/less than any other)
      expected_fraction = 1.0/ @n_matches
      base_quantity = (@count_players / @n_matches)
      fraction_remainder = (@count_players / @n_matches.to_f) - base_quantity
      plus_matches = (fraction_remainder/expected_fraction).ceil.to_i
      (@n_matches-plus_matches).times do
        configuration.push(base_quantity)
      end
      (plus_matches).times do
        configuration.push(base_quantity+1)
      end
    end
    configuration
  end

end