# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here

    # Guest users (not logged in)
    if user.blank?
      # Guests can only view public content
      can :read, :home
      can :read, Article, status: :published
    else
      # Authenticated users can read all published articles
      can :read, Article, status: :published

      # Users can manage their own articles
      can :manage, Article, user_id: user.id

      # Users can read their own drafts and archived articles
      can :read, Article, user_id: user.id

      # Users can manage their own data
      can :manage, User, id: user.id
    end

    # Additional role-based permissions can be added here
    # Example: if user&.admin?
    #   can :manage, :all
    # end
  end
end
