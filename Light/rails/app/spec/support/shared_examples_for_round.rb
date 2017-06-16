RSpec.shared_examples_for 'a round' do |round, number_of_matches, configuration|

  it ('should have '+number_of_matches.to_s+' match') do
    expect(subject[round.to_s]['number_of_matches']).to eq(number_of_matches)
  end

  it ('should have a match configuration of '+configuration.to_s) do
    expect(subject[round.to_s]['matches_configuration']).to match_array(configuration)
  end

end