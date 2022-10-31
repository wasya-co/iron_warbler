
class IronWarbler::StockWatch < ActiveRecord::Base
end


#   # include Mongoid::Document
#   # include Mongoid::Timestamps
#   # store_in collection: 'ish_stock_watches'

#   SLEEP_TIME_SECONDS = 60

#   field :ticker
#   validates_presence_of :ticker

#   NOTIFICATION_TYPES = [ :NONE, :EMAIL, :SMS ]
#   ACTIONS            = NOTIFICATION_TYPES
#   field :notification_type, :type => Symbol, :as => :action
#   validates_presence_of :action

#   field :price, :type => Float
#   validates_presence_of :price

#   DIRECTIONS      = [ :ABOVE, :BELOW ]
#   field :direction, :type => Symbol
#   validates_presence_of :direction

#   ## profile_id is the username/handle
#   belongs_to :profile, :class_name => 'Ish::UserProfile'
#   validates_presence_of :profile

#   def self.active_for profile
#     self.where( profile: profile )
#   end

# end
