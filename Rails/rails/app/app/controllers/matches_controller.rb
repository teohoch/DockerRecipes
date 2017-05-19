class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy, :validate]
  load_and_authorize_resource

  # GET /matches
  # GET /matches.json
  def index
    @matches = Match.all
    if current_user
      @user_matches = current_user.matches
    end
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    @users = User.joins(:user_matches).select('users.*, user_matches.vp, user_matches.victory_position').where('user_matches.match_id' => @match.id)
    if can? :validate, @match
      @user_match = @match.user_matches.find_by(:user_id => current_user.id)
    end
  end

  # GET /matches/new
  def new
    @match = Match.new(:user_matches_attributes => {'0' => {:user_id => current_user.id}})
  end

  # GET /matches/1/edit
  def edit
    @user_matches = @match.user_matches
  end

  # POST /matches
  # POST /matches.json
  def create
    success = Match.new_with_child(match_params)
    respond_to do |format|
      if success[:state]
        format.html { redirect_to success[:object], notice: 'Match was successfully created.' }
        format.json { render :show, status: :created, location: @match }
      else
        helpers.flash_message(:error, success[:errors])
        format.html { render :new }
        format.json { render json: success[:errors], status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    success = @match.update(match_params)
    if success
      @match.user_matches.each do |user_match|
        (user_match.user_id == current_user.id) ? user_match.update(:validated => true) : user_match.update(:validated => false)
      end
    end
    respond_to do |format|
      if success
        format.html { redirect_to @match, notice: t('match.validate.success') }
        format.json { render :show, status: :ok, location: @match }
      else
        format.html { render :edit }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  def validate
    respond_to do |format|
      if @match.user_validation
        format.html { redirect_to back_or_default, notice: t('match.validate.success') }
        format.json { render :show, status: :ok, location: @match }
      else
        format.html { redirect_to back_or_default }
        format.json { render json: @user_match.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
    @match.destroy
    respond_to do |format|
      format.html { redirect_to matches_url, notice: 'Match was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_match
    @match = Match.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def match_params
    params.require(:match).permit(:n_players, :round, :pyramidal_position, :date, :location, user_matches_attributes: [:id, :user_id, :validated, :vp, :_destroy])
  end
end
