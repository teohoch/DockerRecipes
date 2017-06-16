shared_examples_for 'valid started tournament' do
  it 'should be valid' do
    expect(@tournament).to be_valid
  end

  it 'should return status true' do
    expect(@result[:status]).not_to be_truthy
  end

  it 'should not return invalid configuration errors' do
    expect(@result[:errors]).to be_empty
  end
end

describe Tournament, :type => :model do
  it "should have method start" do
    tournament = FactoryGirl.create(:tournament)
    expect(tournament).to respond_to :start
  end

  describe 'Valid Factory' do
    context 'for a basic tournament' do
      it 'should have a valid factory' do
        expect(FactoryGirl.create(:tournament)).to be_valid
      end
    end

    context 'for a Free4All tournament' do
      context 'without inscriptions' do
        before(:all) do
          @tournament = FactoryGirl.create(:tournament, :free4all)
        end

        it 'should have a valid factory' do
          expect(@tournament).to be_valid
        end

        it "should be Free4All" do
          expect(@tournament.mode).to eq(-1)
        end
      end

      context 'with 8 inscriptions' do
        before(:all) do
          temp = FactoryGirl.create(:tournament, :free4all, :with_inscriptions, number_players: 8, n_registered: 8)
          @tournament = Tournament.find(temp.id)
        end

        it 'should have a valid factory' do
          expect(@tournament).to be_valid
        end

        it "should be Free4All" do
          expect(@tournament.mode).to eq(-1)
        end

        it 'should have 8 inscriptions' do
          expect(@tournament.registered).to eq(8)
          expect(@tournament.inscriptions.count).to eq(8)
        end

        it 'should have valid inscriptions' do
          @tournament.inscriptions.each do |inscription|
            expect(inscription).to be_valid
          end
        end
      end

      context 'with 16 inscriptions' do
        before(:all) do
          temp = FactoryGirl.create(:tournament, :free4all, :with_inscriptions, number_players: 16, n_registered: 16)
          @tournament = Tournament.find(temp.id)
        end

        it 'should have a valid factory' do
          expect(@tournament).to be_valid
        end

        it "should be Free4All" do
          expect(@tournament.mode).to eq(-1)
        end

        it 'should have 8 inscriptions' do
          expect(@tournament.registered).to eq(16)
        end

        it 'should have valid inscriptions' do
          expect(@tournament.inscriptions.count).to eq(16)
          @tournament.inscriptions.each do |inscription|
            expect(inscription).to be_valid
          end
        end
      end

    end

    context 'for a Pyramidal tournament' do
      context 'without inscriptions' do
        before(:all) do
          @tournament = FactoryGirl.create(:tournament, :pyramidal)
        end

        it 'should have a valid factory' do
          expect(@tournament).to be_valid
        end

        it "should be Pyramidal" do
          expect(@tournament.mode).to be_between(1, 5)
        end
      end

      context 'with 8 inscriptions' do
        before(:all) do
          temp = FactoryGirl.create(:tournament, :pyramidal, :with_inscriptions, number_players: 16, n_registered: 16)
          @tournament = Tournament.find(temp.id)
        end

        it 'should have a valid factory' do
          expect(@tournament).to be_valid
        end

        it "should be Pyramidal" do
          expect(@tournament.mode).to be_between(1, 5)
        end

        it 'should have 8 inscriptions' do
          expect(@tournament.registered).to eq(16)
        end

        it 'should have valid inscriptions' do
          expect(@tournament.inscriptions.count).to eq(16)
          @tournament.inscriptions.each do |inscription|
            expect(inscription).to be_valid
          end
        end
      end

      context 'with 16 inscriptions' do
        before(:all) do
          temp = FactoryGirl.create(:tournament, :pyramidal, :with_inscriptions, number_players: 16, n_registered: 16)
          @tournament = Tournament.find(temp.id)
        end

        it 'should have a valid factory' do
          expect(@tournament).to be_valid
        end

        it "should be Pyramidal" do
          expect(@tournament.mode).to be_between(1, 5)
        end

        it 'should have 8 inscriptions' do
          expect(@tournament.registered).to eq(16)
        end

        it 'should have valid inscriptions' do
          expect(@tournament.inscriptions.count).to eq(16)
          @tournament.inscriptions.each do |inscription|
            expect(inscription).to be_valid
          end
        end
      end

    end

  end

  describe 'Start the tournament' do
    context 'in free4all mode with 8 participants and 2 rounds' do
      before(:all) do
        @tournament = FactoryGirl.create(:tournament, :with_inscriptions, :free4all, number_players: 8, rounds: 2, n_registered: 8)
        @result = @tournament.start
        @tournament.reload
      end

      it 'should be valid' do
        expect(@tournament).to be_valid
      end

      it "should return status true" do
        expect(@result[:status]).to be_truthy
      end

      it "should not return any errors" do
        expect(@result[:errors].empty?).to be_truthy
      end

      it 'should have a ongoing status' do
        expect(@tournament.status).to eq(1)
      end

      it 'should have 4 matches' do
        expect(@tournament.matches.size).to eq(4)
      end

      it 'should have 2 rounds' do
        expect(@tournament.rounds).to eq(2)
      end

      it 'should have 2 matches in the first round' do
        round_matches = 0
        @tournament.matches.each do |match|
          if match.round == 1
            round_matches += 1
          end
        end
        expect(round_matches).to eq(2)
      end

      it 'should have 2 matches in the second round' do
        round_matches = 0
        @tournament.matches.each do |match|
          if match.round == 2
            round_matches += 1
          end
        end
        expect(round_matches).to eq(2)
      end

      it 'should not have more than 2 similarities between matches' do
        base_matches = @tournament.match_ids
        @tournament.matches.each do |match|
          similarities = 0
          filtered_matches = base_matches.dup
          filtered_matches.delete(match.id)
          filtered_matches.each do |id|
            intersection = match.user_ids & Match.find(id).user_ids
            if intersection.size >= 2
              similarities += 1
            end
          end
          expect(similarities).to be <= 2
        end
      end
    end

    context 'in pyramidal mode' do
      context 'with 8 participants' do
        before(:all) do
          @tournament = FactoryGirl.create(:tournament, :with_inscriptions, :pyramidal, number_players: 8, n_registered: 8)
          @result = @tournament.start
          @tournament.reload
        end

        it 'should be valid' do
          expect(@tournament).to be_valid
        end

        it "should return status false" do
          expect(@result[:status]).not_to be_truthy
        end

        it "should return invalid configuration errors" do
          expect(@result[:errors]).not_to be_empty
        end
      end

      context 'with 9 participants' do
        before(:all) do
          @tournament = FactoryGirl.create(:tournament, :with_inscriptions, :pyramidal, number_players: 9, n_registered: 9)
          @result = @tournament.start
          @tournament.reload
        end

        describe 'Structure' do
          subject {@tournament.structure}
          it 'should not be nil' do
            expect(subject).not_to be_nil
          end

          it 'should not be empty' do
            expect(subject).not_to be_empty
          end

          it 'should be a Hash' do
            expect(subject).to be_a Hash
          end

          it 'should have a numeric keys' do
            expect(subject.keys).to all(match('\d+'))
          end
          it 'should have 2 round' do
            expect(subject.keys.count).to eq(2)
          end
          describe 'Round 1' do
            it_should_behave_like 'a round', 0, 3, [3, 3, 3]
          end
          describe 'Round 2' do
            it_should_behave_like 'a round', 1, 1, [3]
          end
        end
        describe 'Associated Matches' do
          it_should_behave_like 'Associated Matches', {0 => {:number_of_matches => 3, :matches_configuration => [3, 3, 3]}, 1 => {:number_of_matches => 1, :matches_configuration => [3]}}, 4
        end
      end

      context 'with 16 participants' do
        before(:all) do
          @tournament = FactoryGirl.create(:tournament, :with_inscriptions, :pyramidal, number_players: 16, n_registered: 16)
          @result = @tournament.start
          @tournament.reload
        end

        describe 'Structure' do
          subject {@tournament.structure}
          it 'should not be nil' do
            expect(subject).not_to be_nil
          end

          it 'should not be empty' do
            expect(subject).not_to be_empty
          end

          it 'should be a Hash' do
            expect(subject).to be_a Hash
          end

          it 'should have a numeric keys' do
            expect(subject.keys).to all(match('\d+'))
          end
          it 'should have 2 round' do
            expect(subject.keys.count).to eq(2)
          end
          describe 'Round 1' do
            it_should_behave_like 'a round', 0, 4, [4, 4, 4, 4]
          end
          describe 'Round 2' do
            it_should_behave_like 'a round', 1, 1, [4]
          end
        end
      end


    end

  end

end