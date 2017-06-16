class HomeController < ApplicationController
  def index
    @users_general = User.all.where.not(position_general: -1).order(:position_general)
    @users_free = User.all.where.not(position_free: -1).order(:position_free)
    @users_tournament = User.all.where.not(position_tournament: -1).order(:position_tournament)
  end

  def show
  end
end
