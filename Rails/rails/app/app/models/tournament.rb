class Tournament < ApplicationRecord
  belongs_to :officer, :class_name => 'User'
  has_many :inscriptions
  has_many :users, through: :inscriptions
  has_many :matches
  attr_accessor :general_mode

  validates_presence_of :name, :number_players, :prize, :entrance_fee, :officer_id, :date, :rounds, :mode
  validates :board_size, inclusion: {in: [4,6]}
  validates :number_players, inclusion: {in: 3..16 }
  validates :mode, inclusion: { in: -1..5}

  def start

    result = (self.mode ==-1) ? start_free4all : start_pyramidal

    if result[:status]
      self.status=1
      self.current_round = 0
      self.save
    end
    result
  end

  MODES = {(I18n.t 'tournamet_modes.free4all') => -1,
           (I18n.t 'tournamet_modes.pyramidal') => 0}

  PYRAMIDAL_MODES = {
      (I18n.t 'tournamet_modes.not_allowed') => -2,
      (I18n.t 'tournamet_modes.instantwinner') => 0,
      (I18n.t 'tournamet_modes.onewinner') => 1,
      (I18n.t 'tournamet_modes.twowinner') => 2,
      (I18n.t 'tournamet_modes.threewinner') => 3,
      (I18n.t 'tournamet_modes.fourwinner') => 4,
      (I18n.t 'tournamet_modes.fivewinner') => 5
  }

  private

  def start_free4all
    status = true
    errors = []
    selector = RoundSelector.new(self.rounds, self.users.to_a, self.board_size)
    round_matches = selector.select_all_rounds

    round_matches.each_with_index do |round, round_number|
      round.each do |match|
        user_attributes = {}
        match.each do |user|
          user_attributes[user[:id]] = {:user_id => user[:id]}
        end

        match_parameters = {
            :n_players => match.count,
            :round => round_number+1,
            :tournament_id => self.id,
            :user_matches_attributes => user_attributes
        }
        new_match = Match.new_with_child(match_parameters)
        unless new_match[:status]
          status = false
          errors.push(new_match[:errors])
          break
        end
      end

      unless status
        break
      end
    end
    {:status => status, :errors => errors}
  end

  def start_pyramidal
    status = true
    errors = []
    object = nil
    selector = PyramidGenerator.generate(self.board_size, self.mode, self.users.to_a)
    if selector[:status]
      object = selector[:object]
      all_rounds_created = []
      previous_round_ids = [nil]
      self.structure = selector[:object][:general_configuration]
      self.save
      self.reload

      keys = self.structure.keys.sort!.reverse!
      first = true

      keys.each do |key|
        current_round_ids = []
        if first or self.mode == 0
          first = false
          final_match = Match.new(
              :tournament_id => self.id,
              :round => key,
              :pyramidal_position => 0,
              :expected_number_players => self.structure[key]['matches_configuration'][0])


          if final_match.save
            current_round_ids.push(final_match.id)
          else
            status = false
            errors.push(ArgumentError.new)
            break
          end
        else
          round_conf = self.structure[key]['matches_configuration'].dup
          round_number_of_matches = self.structure[key]['number_of_matches']
          current_position = 0

          round_number_of_matches.times do |index|
            if round_conf[current_position] != 0
              round_conf[current_position] = round_conf[current_position] - self.mode
            else
              current_position = current_position + 1
            end
            if key == '0'
              user_attributes = {}
              selector[:object][:first_round][index].each do |user|
                user_attributes[user.id] = {:user_id => user.id}
              end
              match = Match.new_with_child(:tournament_id => self.id,
                                           :round => key,
                                           :pyramidal_position => index,
                                           :consumer_id => previous_round_ids[current_position],
                                           :user_matches_attributes => user_attributes)
              unless match[:status]
                status = false
                errors.push(ArgumentError.new)
              end
            else
              match = Match.new(
                  :tournament_id => self.id,
                  :round => key,
                  :pyramidal_position => index,
                  :consumer_id => previous_round_ids[current_position],
                  :expected_number_players => self.structure[key]['matches_configuration'][index])
              unless match.save
                status = false
                errors.push(ArgumentError.new)
              end
            end
          end
        end
        previous_round_ids = current_round_ids
        all_rounds_created.concat(current_round_ids)
      end

    else
      status = false
      errors = selector[:errors]
    end
    if status
      self.rounds = self.structure.count
    end
    {:status => status, :errors => errors, :object => status ? object : nil}
  end
end

