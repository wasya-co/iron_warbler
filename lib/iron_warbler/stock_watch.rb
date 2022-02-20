
class IronWarbler::StockWatch
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'ish_stock_watches'

  SLEEP_TIME_SECONDS = 60

  field :ticker
  field :email # @TODO: move this back into profile

  NOTIFICATION_TYPES = [ :NONE, :EMAIL, :SMS ]
  ACTIONS            = NOTIFICATION_TYPES
  NOTIFICATION_NONE  = :NONE
  NOTIFICATION_EMAIL = :EMAIL
  NOTIFICATION_SMS   = :SMS
  field :notification_type, :type => Symbol, :as => :action

  field :price, :type => Float

  DIRECTIONS      = [ :ABOVE, :BELOW ]
  DIRECTION_ABOVE = :ABOVE
  DIRECTION_BELOW = :BELOW
  field :direction, :type => Symbol

  ## profile_id is the username/handle
  belongs_to :profile, :class_name => 'Ish::UserProfile'
  validates_presence_of :profile

  def self.active_for profile
    self.where( profile: profile )
  end

end
