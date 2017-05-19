class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    user ||= User.new # guest user (not logged in)

    can :read, Tournament
    can :create, Tournament
    can :update, Tournament, :officer_id => user.id, :status => 0
    can :destroy, Tournament, :officer_id => user.id
    can :register, Tournament do |tournament|
      tournament.inscriptions.find_by(:user_id => user.id).nil? and tournament.status==0 and user.new_record? == false
    end
    can :unregister, Tournament do |tournament|
      tournament.status==0 and not tournament.inscriptions.find_by(:user_id => user.id).nil?  and user.new_record? == false
    end
    can :start, Tournament, :officer_id => user.id, :status => 0
    can :end, Tournament, :officer_id => user.id, :status => 1

    can :read, Match
    can :create, Match, user.new_record? => true
    can :update, Match do |match|
      result = false
      unless match.validated
        match.users.each do |us|
          if us.id == user.id
            result = true
          end
        end
      end
      result
    end
    can :destroy, Match do |match|
      result = false
      unless match.validated
        match.users.each do |us|
          if us.id == user.id
            result = true
          end
        end
      end
      result
    end
    can :validate, Match do |match|
      participant = match.user_matches.find_by(:user_id => user.id)
      local_validated = false
      if participant
        local_validated = participant.validated
      end
      composition = true
      match.user_matches.each do |user_match|
        if user_match.vp.nil?
          composition = false
        end
      end

      tournament_round = true
      unless match.tournament_id.nil? or not match.tournament.must_end_round
        tournament_round = (match.tournament.current_round==match.round)
      end
      # TODO Revise these conditions
      (not participant.nil? and not local_validated and not match[:validated] and tournament_round and composition)
    end

    can :read, Inscription
    can :create, Inscription
    can :destroy, Inscription
    can :update, Inscription

  end
end
