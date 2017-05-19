require 'support/shared_examples_for_round'

describe PyramidGenerator do

  shared_examples_for 'a correct success output object' do
    it 'should output status True' do
      expect(@result[:status]).to be_truthy
    end

    it 'should output no errors' do
      expect(@result[:errors].empty?).to be_truthy
    end

    it 'should output a object of type hash' do
      expect(subject).to be_a Hash
    end

    it 'should respond to general_configuration' do
      expect(subject).to have_key :general_configuration
    end

    it 'should respond to first_round' do
      expect(subject).to have_key :first_round
    end

    describe 'general configuration' do

      it 'should contain a hash' do
        expect(subject[:general_configuration]).to be_a Hash
      end

      it 'should be a hash with numeric keys, starting on 0' do
        expect(subject[:general_configuration].empty?).to be_falsey
        temp = subject[:general_configuration].keys.sort!
        expect(temp.first).to eq(0)
        temp.each_with_index do |round, index|
          expect(round).to be_a Integer
          expect(round).to eq(index)
        end
      end


        describe 'every round' do
          it 'should be a hash' do
            subject[:general_configuration].each do |_, content|
              expect(content).to be_a Hash
            end
          end

          it 'should not be empty' do
            subject[:general_configuration].each do |_, content|
              expect(content).not_to be_empty
            end
          end

          it 'should have a numer_of_matches key' do
            subject[:general_configuration].each do |_, content|
              expect(content).to have_key :number_of_matches
            end
          end

          it 'should habe a matches_configuration key' do
            subject[:general_configuration].each do |key, content|
              expect(content).to have_key :matches_configuration
            end
          end

          describe 'Number of matches' do
            it 'should be a number' do
              subject[:general_configuration].each do |_, content|
                expect(content[:number_of_matches]).to be_a Integer
              end
            end
            it 'should be a bigger than 0' do
              subject[:general_configuration].each do |_, content|
                expect(content[:number_of_matches]).to be > 0
              end
            end
          end

          describe 'Matches Configuration' do
            it 'should be an Array' do
              subject[:general_configuration].each do |_, content|
                expect(content[:matches_configuration]).to be_a Array
              end
            end
            it 'should only contain numbers' do
              subject[:general_configuration].each do |_, content|
                expect(content[:matches_configuration]).to all(be_a Integer)
              end
            end
            it 'the numbers should only be between 3 and the boardsize' do
              subject[:general_configuration].each do |_, content|
                expect(content[:matches_configuration]).to all(be_between(3,@board_mode))
              end
            end
          end

        end
    end

    describe 'first_round' do

      it 'should have the same number of matches as the first round of general_configuration' do
        expect(subject[:first_round].count).to eq(subject[:general_configuration][0][:number_of_matches])
      end

      it 'should have the same number of players in each match as indicated in the general_configuration' do
        round_conf = subject[:first_round].map{|match| match.count}
        expect(round_conf).to match_array(subject[:general_configuration][0][:matches_configuration])
      end

      it 'should contain the ids of the users provided, without repetition' do
        expect(subject[:first_round]).not_to be_empty
        used_ids = subject[:first_round].flatten

        @users.each do |user|
          expect(used_ids.count(user)).to eq(1)
        end

      end
    end
  end

  shared_examples_for 'a correct failure output object' do
    it 'should output status False' do
      expect(@result[:status]).to be_falsey
    end

    it 'should output a list of errors' do
      expect(@result[:errors].empty?).to be_falsey
    end

    it 'should output Argument error with minimum participants message' do
      found = false
      @result[:errors].each do |error|
        if error.is_a?(ArgumentError) && (error.message == I18n.t('pyramid_generator.minimum_participants') || error.message == I18n.t('pyramid_generator.invalid_parameter_combination'))
          found = true
          break
        end
      end
      expect(found).to be_truthy
    end

    it 'should output a null object' do
      expect(@result[:object]).to be_nil
    end

  end

  it 'should have method generate' do
    expect(PyramidGenerator).to respond_to :generate
  end

  context 'in 4 player mode' do

    before(:all) do
      @board_mode = 4
    end

    context 'with 1 winner' do

      before(:all) do
        @n_winners = 1
      end

      context 'with 2 participants' do
        before(:all) do
          @n_participants = 2
          @users = FactoryGirl.create_list(:user, @n_participants).map { |user| user.id }
          @result = PyramidGenerator.generate(@board_mode, @n_winners, @users)
        end

        it_should_behave_like 'a correct failure output object'

      end

      context 'with 3 participants' do
        before(:all) do
          @n_participants = 3
          @users = FactoryGirl.create_list(:user, @n_participants).map { |user| user.id }
          @result = PyramidGenerator.generate(@board_mode, @n_winners, @users)
        end

        subject { @result[:object] }

        it_should_behave_like 'a correct success output object', @users

        it 'should have 1 round' do
          expect(subject[:general_configuration].keys.count).to eq(1)
        end

        context 'Round 1' do
          it_should_behave_like 'a round', 0, 1, [3]
        end

      end

      context 'with 4 participants' do
        before(:all) do
          @n_participants = 4
          @users = FactoryGirl.create_list(:user, @n_participants).map { |user| user.id }
          @result = PyramidGenerator.generate(@board_mode, @n_winners, @users)
        end

        subject { @result[:object] }

        it_behaves_like 'a correct success output object', @users

        it 'should have 1 round' do
          expect(subject[:general_configuration].keys.count).to eq(1)
        end

        context 'Round 1' do
          it_should_behave_like 'a round', 0, 1, [4]
        end

      end

      context 'with 5 participants' do
        before(:all) do
          @n_participants = 5
          @users = FactoryGirl.create_list(:user, @n_participants).map { |user| user.id }
          @result = PyramidGenerator.generate(@board_mode, @n_winners, @users)
        end

        it_should_behave_like 'a correct failure output object'
      end

      context 'with 6 participants' do
        before(:all) do
          @n_participants = 6
          @users = FactoryGirl.create_list(:user, @n_participants).map { |user| user.id }
          @result = PyramidGenerator.generate(@board_mode, @n_winners, @users)
        end

        it_should_behave_like 'a correct failure output object'
      end

      context 'with 7 participants' do
        before(:all) do
          @n_participants = 7
          @users = FactoryGirl.create_list(:user, @n_participants).map { |user| user.id }
          @result = PyramidGenerator.generate(@board_mode, @n_winners, @users)
        end

        it_should_behave_like 'a correct failure output object'
      end

      context 'with 8 participants' do
        before(:all) do
          @n_participants = 8
          @users = FactoryGirl.create_list(:user, @n_participants).map { |user| user.id }
          @result = PyramidGenerator.generate(@board_mode, @n_winners, @users)
        end

        it_should_behave_like 'a correct failure output object'
      end

      context 'with 9 participants' do
        before(:all) do
          @n_participants = 9
          @users = FactoryGirl.create_list(:user, @n_participants).map { |user| user.id }
          @result = PyramidGenerator.generate(@board_mode, @n_winners, @users)
        end

        subject { @result[:object] }

        it_behaves_like 'a correct success output object', @users

        it 'should have 2 rounds' do
          expect(subject[:general_configuration].keys.count).to eq(2)
        end

        context 'Round 1' do
          it_should_behave_like 'a round', 0, 3, [3, 3, 3]
        end

        context 'Round 2' do
          it_should_behave_like 'a round', 1, 1, [3]
        end

      end

      context 'with 16 participants' do
        before(:all) do
          @n_participants = 16
          @users = FactoryGirl.create_list(:user, @n_participants).map { |user| user.id }
          @result = PyramidGenerator.generate(@board_mode, @n_winners, @users)
        end

        subject { @result[:object] }

        it_behaves_like 'a correct success output object', @users

        it 'should have 2 rounds' do
          expect(subject[:general_configuration].keys.count).to eq(2)
        end

        context 'Round 1' do
          it_should_behave_like 'a round', 0, 4, [4, 4, 4, 4]
        end

        context 'Round 2' do
          it_should_behave_like 'a round', 1, 1, [4]
        end

      end

    end
  end
end



