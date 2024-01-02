

class Iro::Stock
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_stocks'

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ 'active', 'inactive' ]
  def self.active
    where( status: STATUS_ACTIVE )
  end

  field :ticker
  validates :ticker, uniqueness: true, presence: true


end
