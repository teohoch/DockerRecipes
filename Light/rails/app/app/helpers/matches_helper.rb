module MatchesHelper
  def victory_position_human(position)
    case position
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
      else
        I18n.t 'invalid_place'
    end
  end
end
