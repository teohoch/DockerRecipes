class PyramidGenerator


  def self.generate(board_mode, n_winners, player_ids)
    participants = player_ids.count
    status = true
    errors = []
    object = nil

    result = self.generator(board_mode, n_winners, participants)
    case result[:status]
      when -2
        status = false
        errors.push(ArgumentError.new(I18n.t('pyramid_generator.minimum_participants')))
      when 0
        object = {
            :general_configuration => result[:rounds],
            :first_round => self.first_round_assigner(result[:rounds][0][:matches_configuration], player_ids)}
      else
        status = false
        errors.push(ArgumentError.new(I18n.t('pyramid_generator.invalid_parameter_combination')))
    end
    {:status => status, :errors => errors, :object => object}
  end

  private

  # @param [Integer] board_mode The maximum number of players allowed in each match
  # @param [Integer] n_winners  The number of winners in each match
  # @param [Integer] players  The total number of players
  # @param [Integer] round The current round, counting from 0
  # @return [Hash] opts
  # @option opts [Integer] :status The status of the operation. -2 is minimum of players not met, -1 is a invalid configuration and 0 is a successful operation
  # @option opts Hash  :rounds Returns a Hash of Rounds

  def self.generator(board_mode, n_winners, players, round=0) #:doc:
    output = {:status => nil, :rounds => {}}
    inf = 1.0/0
    case players
      when -inf..2
        output[:status] = -2
      when 3..board_mode
        output[:status] = 0
        output[:rounds][round] = {:number_of_matches => 1, :matches_configuration => [players]}
      else
        flag = false
        lower_bound = (players.to_f/board_mode).ceil
        upper_bound = (players.to_f/3.0).ceil

        (lower_bound..upper_bound).each do |number_of_matches|
          if number_of_matches * n_winners < players
            current_round = []
            remaining = players - (3 * number_of_matches)

            # Check if it fits perfectly in N boxes
            if remaining == 0
              number_of_matches.times { current_round.push(3) }
            elsif remaining < 0
              break
            else
              full_add = remaining/number_of_matches
              if (3+full_add)<= board_mode and (3+full_add) * number_of_matches <= players
                number_of_matches.times { current_round.push(3+full_add) }
                current_count = number_of_matches * (3+full_add)
                unless current_count >= players
                  current_round.each_with_index do |match, index|
                    current_round[index] = match + 1
                    current_count = current_count + 1
                    if current_count >= players
                      break
                    end
                  end
                end
                minimum_size_flag = false
                current_round.each do |match|
                  minimum_size_flag= (match > n_winners) ? nil : true
                end
                if minimum_size_flag
                  break
                end
              else
                break
              end
            end

            next_recursion = self.generator(board_mode, n_winners, n_winners*number_of_matches, round + 1)
            if next_recursion[:status] == 0
              output[:status] = 0
              output[:rounds].merge!(next_recursion[:rounds])
              output[:rounds][round] = {:number_of_matches => number_of_matches, :matches_configuration => current_round}
              flag = true
              break
            end
          end
        end
        unless flag
          output[:status]=-1
          output[:rounds]= []
        end
    end
    output
  end

  # @param [Array<Integer>] first_round_config The match configurations for the first round. Should be an array of integers, representing the number of players in each round
  # @param [Integer] player_ids The ids of the users available for the first round
  # @return [Array<[Array<Integer>]>] Returns an array of Matches_representations, which are in themselves an array of user ids
  def self.first_round_assigner(first_round_config, player_ids) #:doc:
    output = []
    player_ids_local = player_ids.dup
    first_round_config.each do |match|
      generated_match = self.generate_random(match, player_ids_local)
      output.push(generated_match[0])
      player_ids_local = generated_match[1]
    end
    output
  end

  def self.generate_random(count, aval_players_ids) #:doc:
    match_ids=[]
    count.times do
      rand = rand(aval_players_ids.count)
      match_ids.push(aval_players_ids.slice!(rand))
    end
    [match_ids.sort, aval_players_ids]
  end
end