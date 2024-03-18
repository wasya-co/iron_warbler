
class Iro::Stock
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'iro_stocks'

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ nil, 'active', 'inactive' ]
  def self.active
    where( status: STATUS_ACTIVE )
  end
  field :status, default: STATUS_ACTIVE

  field :ticker
  validates :ticker, uniqueness: true, presence: true
  index({ ticker: -1 }, { unique: true })

  field :last, type: :float
  field :options_price_increment, type: :float

  has_many :positions,  class_name: 'Iro::Position', inverse_of: :stock
  has_many :strategies, class_name: 'Iro::Strategy', inverse_of: :stock
  has_many :purses,     class_name: 'Iro::Purse',    inverse_of: :stock

  def to_s
    ticker
  end
  def self.list
    [[nil,nil]] + all.map { |sss| [ sss.ticker, sss.id ] }
  end
  def self.tickers_list
    [[nil,nil]] + all.map { |sss| [ sss.ticker, sss.ticker ] }
  end
end
