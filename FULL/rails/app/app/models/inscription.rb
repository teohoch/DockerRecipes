class Inscription < ApplicationRecord
  belongs_to :user
  belongs_to :tournament, counter_cache: :registered

  def destroy
    if self.tournament.status != 0
      self.errors.add(:base, (I18n.t 'activerecord.errors.models.inscription.attributes.base.oncourse'))
      false
    else
      super
    end
  end
end
