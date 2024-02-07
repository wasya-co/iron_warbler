
class Iro::Alert
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_alerts'

  # SLEEP_TIME_SECONDS = Rails.env.production? ? 60 : 15

  DIRECTION_ABOVE = 'ABOVE'
  DIRECTION_BELOW = 'BELOW'
  def self.directions_list
    [ nil, DIRECTION_ABOVE, DIRECTION_BELOW ]
  end

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ nil, 'active', 'inactive' ]
  field :status, default: STATUS_ACTIVE
  def self.active
    where( status: STATUS_ACTIVE )
  end

  field :class_name, default: 'Iro::Stock'
  validates :class_name, presence: true

  field :symbol
  validates :symbol, presence: true

  field :direction
  validates :direction, presence: true

  field :strike
  validates :strike, presence: true

end
