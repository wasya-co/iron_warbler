
class IronWarbler::Ability
  include ::CanCan::Ability

  def initialize user

    #
    # signed in user
    #
    if !user.blank?


      #
      # role admin
      #
      if user.profile && [ :admin ].include?( user.profile.role_name )
        can [ :manage ], ::IronWarbler::StockWatch
      end

      #
      # every logged in user
      #
      can [ :index ], ::IronWarbler::StockWatch

    end

    #
    # anonymous user
    #
    user ||= ::User.new

    can [ :open_permission ], IronWarbler::Ability

  end
end
