class Match < ApplicationRecord
  include ActiveModel::Validations
  has_many :user_matches, dependent: :destroy
  has_many :users, through: :user_matches
  belongs_to :tournament
  belongs_to :consumer, class_name: "Match"
  has_many :feeders, class_name: "Match", foreign_key: 'consumer_id'
  accepts_nested_attributes_for :user_matches
  validates :date, :location, client_presence: true

  scope :round, -> (round) {where(round: round)}

  def validated_human
    if self.validated
      I18n.t 'positive'
    else
      I18n.t 'negatory'
    end
  end

  def status
    self.validated ? (I18n.t :ended_f) : (I18n.t :waiting)
  end

  def validated_count
    self.user_matches.where(:validated => true).count
  end

  def user_validation
    current_user_match = @match.user_matches.find_by_user_id(current_user.id)
    success = (not current_user_match.nil?)
    if success && current_user_match.update(:validated => true)
      @match.validate_record
    end
    success
  end

  def validate_record
    if not self.validated and self.validated_count >= 2
      self.update(validated: true)

      self.set_rankings
      self.set_victory_positions

      self.user_matches.each do |user_match|
        user = user_match.user
        user_match.update(:elo_general => user.elo_general, :elo_tournament => user.elo_tournament, :elo_free => user.elo_free)
        user.increment(:matches_played)
        user.increment(:elo_general, user_match[:elo_general_change])
        user.increment(:elo_tournament, user_match[:elo_tournament_change])
        user.increment(:elo_free, user_match[:elo_free_change])

        user.save
      end

      if self.tournament_id.nil?
        User.update_position_general
      else
        User.update_position_tournament
      end
      User.update_position_free
    end
  end

  def set_victory_positions
    user_matches = self.user_matches.order(vp: :desc)
    user_matches.each_with_index do |user_match, index|
      user_match.update(:victory_position => index)
    end
  end

  def set_rankings
    general = self.tournament.nil?
    tournament = (not self.tournament.nil?)

    attributes_general = []
    attributes_free = []
    attributes_tournament = []
    winner = true
    user_matches_ordered = self.user_matches.order(vp: :desc)

    user_matches_ordered.each do |elem|
      elem_user = User.find(elem[:user_id])
      general ? attributes_general.push({:rating => elem_user.elo_general, :winner => winner, :provisional => (elem_user.matches_played<=2)}) : nil
      (general or tournament) ? attributes_free.push({:rating => elem_user.elo_free, :winner => winner, :provisional => (elem_user.matches_played<=2)}) : nil
      tournament ? attributes_tournament.push({:rating => elem_user.elo_tournament, :winner => winner, :provisional => (elem_user.matches_played<=2)}) : nil
      winner = false
    end

    if general
      calculator_general = Elo_Calculator.new(attributes_general)
      ratings_general = calculator_general.calculate_rating
      ratings_general.zip user_matches_ordered.each do |rating, user_match|
        user_match.update(:elo_general_change => rating)
      end
    end

    if general or tournament
      calculator_free = Elo_Calculator.new(attributes_free)
      ratings_free = calculator_free.calculate_rating
      ratings_free.zip user_matches_ordered.each do |rating, user_match|
        user_match.update(:elo_free_change => rating)
      end
    end

    if tournament
      calculator_tournament = Elo_Calculator.new(attributes_tournament)
      ratings_tournament = calculator_tournament.calculate_rating
      ratings_tournament.zip user_matches_ordered.each do |rating, user_match|
        user_match.update(:elo_tournament_change => rating)
      end
    end
  end

  def self.new_with_child(match_params)
    #TODO rework this shit, and make tests!
    success = true
    error_list = []

    match = Match.new(
        :date => match_params[:date],
        :location => match_params[:location],
        :tournament_id => (match_params.key?(:tournament_id) ? match_params[:tournament_id] : nil),
        :consumer_id => (match_params.key?(:consumer_id) ? match_params[:consumer_id] : nil),
        :round => match_params[:round],
        :pyramidal_position => (match_params.key?(:pyramidal_position) ? match_params[:pyramidal_position] : nil),
        :expected_number_players => (match_params.key?(:expected_number_players) ? match_params[:expected_number_players] : match_params[:user_matches_attributes].count))


    n_valid = 0
    if match.save
      elems_array = []
      match_params[:user_matches_attributes].each do |_, elem|
        user_match = UserMatch.new(:user_id => elem[:user_id],
                                   :vp => elem[:vp],
                                   :match_id => match.id,
                                   :validated => elem.key?(:validated) ? elem[:validated] : false)
        n_valid = (user_match.validated ? n_valid + 1 : n_valid)

        unless user_match.save
          error_list.push(user_match.errors)
          success = false
          break
        end
        elems_array.push(user_match)
      end
    else
      error_list.push(match.errors)
      success = false
    end

    if n_valid >= 2
      match.validated = true
      unless match.save
        success = false
        error_list.push(match.errors)
      end
    end

    unless success
      match.destroy
    end
    {:status => success, :errors => error_list, :object => (success ? match : nil)}
  end

end


