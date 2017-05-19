RSpec.shared_examples_for "Associated Matches" do |configuration, number_of_matches|
  it ('should have '+number_of_matches.to_s+' matches') do
    expect(@tournament.matches.count).to eq(number_of_matches)
  end
  configuration.keys.sort!.each_with_index do |key, index|
    describe ('Associated matches of Round '+key.to_s) do
      before(:all) do
        if key == 0
          @generated_array = []
          @generated_user_configuration = []
          @expected_user_configuration = @result[:object][:first_round].map {|match| match.map {|user| user.id}.sort!}
          @tournament.matches.round(key).each do |match|
            @generated_array.push(match.n_players)
            @generated_user_configuration.push(match.users.to_a.map {|user| user.id}.sort!)
          end
        end
        @round_matches = @tournament.matches.round(key)
      end
      if key == 0

        it ('should have matches with configuration '+ configuration[0][:matches_configuration].to_s) do
          expect(@generated_array).to match_array(configuration[0][:matches_configuration])
        end

        it 'should have matches with correct user configuration' do
          expect(@generated_user_configuration).to match_array(@expected_user_configuration)
        end

      end

      it ('should have ' + configuration[key][:number_of_matches].to_s + (configuration[key][:number_of_matches] >1 ? ' matches' : ' match')) do
        expect(@tournament.matches.round(key).count).to eq(configuration[key][:number_of_matches])
      end

      it 'should have different pyramidal positions' do
        expect(@round_matches.map {|match| match.pyramidal_position}).to match_array((0..configuration[key][:number_of_matches]-1).to_a)
      end

      configuration[key][:number_of_matches].times do |index2|
        describe ('Match ' + index2.to_s) do
          before(:all) do
            @match = @round_matches[index2]
          end
          unless index == 0
            it 'should have feeders' do
              expect(@match.feeders).not_to be_nil
            end
            it 'should have the same number of feeders as the the number of players multiplied by the number of winners' do
              expect(@match.feeders.count).to eq(@match.expected_number_players * @tournament.mode)
            end
          end
          unless index == (configuration.keys.count - 1)
            it 'should have a consumer' do
              expect(@match.consumer).not_to be_nil
            end
          end
        end
      end
    end
  end
end