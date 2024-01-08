
class Iro::Strategy
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_strategies'

  field :slug
  validates :slug, presence: true, uniqueness: true

  has_many :positions, class_name: 'Iro::Position', inverse_of: :strategy

  ## multiple strategies per ticker
  field :ticker
  validates :ticker, presence: true
  index({ ticker: 1 })
  # belongs_to :stock, class_name: 'Iro::Stock', inverse_of: :strategies


  field :buffer_above_water, type: :float
  field :next_max_delta, type: :float
  field :next_min_strike, type: :float
  field :threshold_delta, type: :float
  field :threshold_netp, type: :float

  def self.for_ticker ticker
    where( ticker: ticker )
  end


  def to_s
    slug
  end

  def self.list
    [[nil,nil]] + all.map { |ttt| [ ttt.slug, ttt.id ] }
  end

end
