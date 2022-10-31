
class IronWarbler::Ability
end

#   include ::CanCan::Ability

#   def initialize user

#     #
#     # signed in user
#     #
#     if !user.blank?


#       #
#       # role admin
#       #
#       if user.profile && [ :admin ].include?( user.profile.role_name )
#         can [ :manage ], ::IronWarbler::StockWatch
#         can [ :manage ], ::IronWarbler::OptionWatch
#       end

#       #
#       # every logged in user
#       #
#       can [ :create ], ::IronWarbler::OptionWatch

#       can [ :index ], ::IronWarbler::StockWatch

#       can [ :show ], Ish::UserProfile do |p|
#         user.profile == p
#       end

#     end

#     #
#     # anonymous user
#     #
#     user ||= ::User.new

#     can [ :open_permission ], IronWarbler::Ability

#   end
# end
