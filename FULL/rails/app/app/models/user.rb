class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :inscriptions
  has_many :tournaments, through: :inscriptions

  has_many :officed_tournaments, :class_name => 'Tournament', :foreign_key => 'officer_id'

  has_many :user_matches
  has_many :matches, through: :user_matches


  NEWBIE_THRESHOLD = 2

  def to_label
    self.name
  end

  def position_free
    if self[:position_free] > 0
      self[:position_free]
    else
      I18n.t 'not_asigned'
    end
  end

  def position_general
    if self[:position_general] > 0
      self[:position_general]
    else
      I18n.t 'not_asigned'
    end
  end

  def position_tournament
    if self[:position_tournament] > 0
      self[:position_tournament]
    else
      I18n.t 'not_asigned'
    end
  end


  def self.update_position_general
    sorted = User.all.order('elo_general DESC')
    pos = 0
    last_elo = nil
    sorted.each do |elem|
      if elem[:matches_played]>=NEWBIE_THRESHOLD
        if last_elo != elem[:elo_general]
          last_elo = elem[:elo_general]
          pos = pos + 1
        end
        elem.update(:position_general => pos)
        elem.save
      end
    end
  end

  def self.update_position_free
    sorted = User.all.order('elo_free DESC')
    pos = 0
    last_elo = nil
    sorted.each do |elem|
      if elem[:matches_played]>=NEWBIE_THRESHOLD
        if last_elo != elem[:elo_free]
          last_elo = elem[:elo_free]
          pos = pos + 1
        end
        elem.update(:position_free => pos)
        elem.save
      end
    end
  end

  def self.update_position_tournament
    sorted = User.all.order('elo_tournament DESC')
    pos = 0
    last_elo = nil
    sorted.each do |elem|
      if elem[:matches_played]>=NEWBIE_THRESHOLD
        if last_elo != elem[:elo_tournament]
          last_elo = elem[:elo_tournament]
          pos = pos + 1
        end
        elem.update(:position_tournament => pos)
        elem.save
      end
    end
  end

end
