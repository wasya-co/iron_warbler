
class Iro::Stock
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_stocks'

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ nil, 'active', 'inactive' ]
  def self.active
    where( status: STATUS_ACTIVE )
  end
  field :status

  field :ticker
  validates :ticker, uniqueness: true, presence: true

  field :last, type: :float

  def self.list
  end

  def self.tickers_list
    [nil] + all.map( &:ticker )
  end

  # has_many :strategies, class_name: 'Iro::Strategy', inverse_of: :stock

end
