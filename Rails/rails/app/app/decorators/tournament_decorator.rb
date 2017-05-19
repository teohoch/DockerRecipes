class TournamentDecorator < ApplicationDecorator
  delegate_all

  def attributes
    base = ['name', 'number_players', 'prize', 'entrance_fee', 'date', 'status', 'mode', 'winning_mode', 'rounds', 'current_round', 'board_size', 'registered', 'officer']


    if model.status < 1
      base.delete('rounds')
    end
    unless model.status == 1
      base.delete('current_round')
    end
    unless model.mode >=0
      base.delete('winning_mode')
    end
    base.map{|key| [key, self.send(key)]}
  end

  def mode
    if model.mode == -1
      I18n.t 'tournamet_modes.free4all'
    else
      I18n.t 'tournamet_modes.pyramidal'
    end
  end

  def raw_mode
    model.mode
  end

  def winning_mode
    case model.mode
      when -1
        I18n.t 'tournamet_modes.free4all'
      when 0
        I18n.t 'tournamet_modes.instantwinner'
      when 1
        I18n.t 'tournamet_modes.onewinner'
      when 2
        I18n.t 'tournamet_modes.twowinner'
      when 3
        I18n.t 'tournamet_modes.threewinner'
      when 4
        I18n.t 'tournamet_modes.fourwinner'
      when 5
        I18n.t 'tournamet_modes.fivewinner'
      else
        I18n.t 'invalid'
    end
  end

  def status
    case model.status
      when 0
        I18n.t 'register_phase'
      when 1
        I18n.t 'ongoing'
      when 2
        I18n.t 'finalized'
      else
        I18n.t 'invalid'
    end
  end

  def raw_status
    model.status
  end

  def officer
    model.officer.name
  end

  def current_round
    model.current_round + 1
  end

  def raw_model
    model
  end

  def entrance_fee
    h.number_to_currency(model.entrance_fee, precision: (h.t 'currency_precision'))
  end

  def inscription_button(user, wrapper_class = 'col-md-2 center_block')
    if h.can? :register, model
      h.render partial: 'register_button', locals: {inscription: Inscription.new(:tournament_id => model.id), wrapper_class: wrapper_class}
    else
      if h.can? :unregister, model
        inscription = model.inscriptions.find_by(:user_id => user.id)
        h.content_tag(:div,
                      h.link_to((h.t 'unregister'), inscription, method: :delete, data: {confirm: (h.t 'are_you_sure')}, class: 'btn btn-success'),
                      class: 'col-md-2 center-block')
      end
    end
  end

  def pretty_show
    super(title: h.t('tournament.show.table_name'))
  end

  def show_info
    if model.status != 0
      if model.mode == -1
        ranking_rounds
      else
        nil
      end
    end
  end

  private

    def ranking_rounds(title: h.t('tournament.show.rounds_title'))
      if model.status != 0 and model.mode == -1
        h.render partial: 'ranking_rounds', locals: {matches: model.matches, rounds: model.rounds, title: title}
      end
    end


end
