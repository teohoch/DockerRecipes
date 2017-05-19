describe Match, :type => :model do
  def match_parameter_preparator(n_users = 4, n_valid = 1, tournament = false)
    date = Faker::Date.between(Date.today, 1.month.from_now)
    location = Faker::Address.city

    user_matches_params = {}
    users = []

    validated = n_valid
    n_users.times do |index|
      user = FactoryGirl.create(:user)
      users.push(user)
      user_matches_params[index] = {
          :user_id => "#{user.id}",
          :validated => (validated > 0 ? 'true' : false),
          :vp => Faker::Number.between(1, 10)}
      validated = validated - 1
    end
    {:params => {
        :date => date,
        :location => location,
        :tournament_id => ((tournament) ? tournament : nil),
        :user_matches_attributes => user_matches_params},
     :users => users}
  end

  def new_with_child_template(users = 4, n_valid = 1, tournament = false)
    if tournament
      tournament_object = FactoryGirl.create(:tournament)
      params = match_parameter_preparator(users, n_valid, tournament_object.id)
    else
      params = match_parameter_preparator(users, n_valid, false)
    end

    match = Match.new_with_child(params[:params])

    expect(match[:status]).to eq(true)
    expect(match[:errors].empty?).to eq(true)

    expect(match[:object].date).to eq(params[:params][:date])
    expect(match[:object].location).to eq(params[:params][:location])
    expect(match[:object].validated).to eq(n_valid >=2)

    if tournament
      expect(match[:object].tournament).not_to eq(nil)
      expect(match[:object].tournament.id).to eq(tournament_object.id)
    else
      expect(match[:object].tournament).to eq(nil)
    end
    valid_user_matches = 0
    match[:object].user_matches.each do |user_match|
      expect(params[:users]).to include(user_match.user)
      valid_user_matches = (user_match.validated ? (valid_user_matches + 1) : valid_user_matches)
    end

    expect(valid_user_matches).to eq(n_valid)
  end

  describe 'Valid Factory' do

    context 'for basic default match' do

      subject{FactoryGirl.create(:match)}

      it 'should have a valid factory' do
        expect(subject).to be_valid
      end
      it 'should have 4 assigned players' do
        expect(subject.users.count).to eq(4)
      end

      it 'should have valid players assigned' do
        subject.users.each do |user|
          expect(user).to be_valid
        end
      end

      it 'should not have a tournament assigned' do
        expect(subject.tournament).to be_nil
      end
      it 'should not feed any other match' do
        expect(subject.consumer).to be_nil
      end
    end

    context 'for basic match without players' do

      subject{FactoryGirl.create(:match, number_players: 0)}

      it 'should have a valid factory' do
        expect(subject).to be_valid
      end
      it 'should not have assigned players' do
        expect(subject.users).to be_empty
      end
      it 'should not have a tournament assigned' do
        expect(subject.tournament).to be_nil
      end
      it 'should not feed any other match' do
        expect(subject.consumer).to be_nil
      end
    end

    context 'for basic match with 3 players' do

      subject{FactoryGirl.create(:match, number_players: 3)}

      it 'should have a valid factory' do
        expect(subject).to be_valid
      end
      it 'should have 3 assigned players' do
        expect(subject.users.count).to eq(3)
      end

      it 'should have valid players assigned' do
        subject.users.each do |user|
          expect(user).to be_valid
        end
      end

      it 'should not have a tournament assigned' do
        expect(subject.tournament).to be_nil
      end
      it 'should not feed any other match' do
        expect(subject.consumer).to be_nil
      end
    end

    context 'for basic match with 4 players' do

      subject{FactoryGirl.create(:match, number_players: 4)}

      it 'should have a valid factory' do
        expect(subject).to be_valid
      end
      it 'should have 4 assigned players' do
        expect(subject.users.count).to eq(4)
      end

      it 'should have valid players assigned' do
        subject.users.each do |user|
          expect(user).to be_valid
        end
      end

      it 'should not have a tournament assigned' do
        expect(subject.tournament).to be_nil
      end
      it 'should not feed any other match' do
        expect(subject.consumer).to be_nil
      end
    end

  end


  it 'should Validate match' do
    match = FactoryGirl.create(:match, n_valids: 2)
    match.validate_record
    expect(match[:validated]).to eq(true)

    user_matches = match.user_matches.order(vp: :desc)
    previous = nil
    current_winner = nil
    current_losers = []

    user_matches.each do |user_match|
      unless previous.nil?
        expect(previous[:victory_position]).to be < user_match[:victory_position]
      end
      previous = user_match

      if current_winner.nil?
        current_winner = user_match
      else
        if current_winner[:elo_general_change] < user_match[:elo_general_change]
          current_losers.push(current_winner) unless current_winner.nil?
          current_winner = user_match
        end
      end
    end
    expect(current_winner[:elo_general_change]).to eq(48)
    current_losers.each do |loser|
      expect(loser[:elo_general_change]).to eq(-16)
    end
  end

  it 'should Validate match from user indication' do
    match = FactoryGirl.create(:match, n_valids: 2)
    match.validate_record
    expect(match[:validated]).to eq(true)

    user_matches = match.user_matches.order(vp: :desc)
    previous = nil
    current_winner = nil
    current_losers = []

    user_matches.each do |user_match|
      unless previous.nil?
        expect(previous[:victory_position]).to be < user_match[:victory_position]
      end
      previous = user_match

      if current_winner.nil?
        current_winner = user_match
      else
        if current_winner[:elo_general_change] < user_match[:elo_general_change]
          current_losers.push(current_winner) unless current_winner.nil?
          current_winner = user_match
        end
      end
    end
    expect(current_winner[:elo_general_change]).to eq(48)
    current_losers.each do |loser|
      expect(loser[:elo_general_change]).to eq(-16)
    end
  end

  it 'should assign victory position according to VP' do
    match = FactoryGirl.create(:match)
    match.set_victory_positions
    user_matches = match.user_matches.order(vp: :desc)
    previous = nil
    user_matches.each do |user_match|
      unless previous.nil?
        expect(previous[:victory_position]).to be < user_match[:victory_position]
      end
      previous = user_match
    end


  end

  it 'should Calculate General Elo Changes for equal temporal users' do
    match = FactoryGirl.create(:match)
    match.set_rankings
    current_winner = nil
    current_losers = []
    match.user_matches.each do |user_match|
      if current_winner.nil?
        current_winner = user_match
      else
        if current_winner[:elo_general_change] < user_match[:elo_general_change]
          current_losers.push(current_winner) unless current_winner.nil?
          current_winner = user_match
        end
      end
    end
    expect(current_winner[:elo_general_change]).to eq(48)
    current_losers.each do |loser|
      expect(loser[:elo_general_change]).to eq(-16)
    end
  end

  it 'should Calculate Tournament Elo Changes for equal temporal users' do
    match = FactoryGirl.create(:match, :of_tournament)
    match.set_rankings
    current_winner = nil
    current_losers = []
    match.user_matches.each do |user_match|
      if current_winner.nil?
        current_winner = user_match
      else
        if current_winner[:elo_tournament_change] < user_match[:elo_tournament_change]
          current_losers.push(current_winner) unless current_winner.nil?
          current_winner = user_match
        end
      end

    end
    expect(current_winner[:elo_tournament_change]).to eq(48)
    current_losers.each do |loser|
      expect(loser[:elo_tournament_change]).to eq(-16)
    end
  end

  it 'should Calculate Free Elo Changes for equal temporal users' do
    match = FactoryGirl.create(:match)
    match.set_rankings
    current_winner = nil
    current_losers = []
    match.user_matches.each do |user_match|
      if current_winner.nil?
        current_winner = user_match
      else
        if current_winner[:elo_free_change] < user_match[:elo_free_change]
          current_losers.push(current_winner) unless current_winner.nil?
          current_winner = user_match
        end
      end

    end
    expect(current_winner[:elo_free_change]).to eq(48)
    current_losers.each do |loser|
      expect(loser[:elo_free_change]).to eq(-16)
    end
  end

  it 'should Create a new Regular 4-player Match with the associated user_matches (0 valid)' do
    users = 4
    n_valid = 0
    tournament = false
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Regular 4-player Match with the associated user_matches (1 valid)' do
    users = 4
    n_valid = 1
    tournament = false
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Regular 4-player Match with the associated user_matches (2 valid)' do
    users = 4
    n_valid = 2
    tournament = false
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Regular 6-player Match with the associated user_matches (0 valid)' do
    users = 6
    n_valid = 0
    tournament = false
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Regular 6-player Match with the associated user_matches (1 valid)' do
    users = 6
    n_valid = 1
    tournament = false
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Regular 6-player Match with the associated user_matches (2 valid)' do
    users = 6
    n_valid = 2
    tournament = false
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Tournament 4-player Match with the associated user_matches (0 valid)' do
    users = 4
    n_valid = 0
    tournament = true
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Tournament 4-player Match with the associated user_matches (1 valid)' do
    users = 4
    n_valid = 1
    tournament = true
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Tournament 4-player Match with the associated user_matches (2 valid)' do
    users = 4
    n_valid = 2
    tournament = true
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Tournament 6-player Match with the associated user_matches (0 valid)' do
    users = 6
    n_valid = 0
    tournament = true
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Tournament 6-player Match with the associated user_matches (1 valid)' do
    users = 6
    n_valid = 1
    tournament = true
    new_with_child_template(users, n_valid, tournament)
  end

  it 'should Create a new Tournament 6-player Match with the associated user_matches (2 valid)' do
    users = 6
    n_valid = 2
    tournament = true
    new_with_child_template(users, n_valid, tournament)
  end


end


