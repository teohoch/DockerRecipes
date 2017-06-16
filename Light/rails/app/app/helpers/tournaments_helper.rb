module TournamentsHelper

  def mode_human(mode, complete=false)
    if complete
      case mode
        when 0
          t 'tournamet_modes.free4all'
        when 1
          t 'tournamet_modes.onewinner'
        when 2
          t 'tournamet_modes.twowinner'
        when 3
          t 'tournamet_modes.threewinner'
        when 4
          t 'tournamet_modes.fourwinner'
        when 5
          t 'tournamet_modes.fivewinner'
      end
    else
      if mode ==0
        t 'tournamet_modes.free4all'
      else
        t 'tournamet_modes.pyramidal'
      end

    end

  end

end
