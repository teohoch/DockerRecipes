class UserMatch < ApplicationRecord
  belongs_to :user
  belongs_to :match, counter_cache: :n_players

  POSITION = {
      (I18n.t 'first_place') => 1,
      (I18n.t 'second_place') => 2,
      (I18n.t 'third_place') => 3,
      (I18n.t 'fourth_place') => 4,
      (I18n.t 'fith_place') => 5,
      (I18n.t 'sixth_place') => 6
  }

  def victory_position_human
    case self.victory_position
      when 1
        I18n.t 'first_place'
      when 2
        I18n.t 'second_place'
      when 3
        I18n.t 'third_place'
      when 4
        I18n.t 'fourth_place'
      when 5
        I18n.t 'fith_place'
      when 6
        I18n.t 'sixth_place'
    end
  end

  def validated_human
    if self.validated
      I18n.t 'positive'
    else
      I18n.t 'negatory'
    end
  end
end
