
class IronWarbler::Ability
  include ::CanCan::Ability

  def initialize user

    #
    # signed in user
    #
    if !user.blank?

    end

    #
    # anonymous user
    #
    user ||= ::User.new

    can [ :open_permission ], IronWarbler::Ability

  end
end
