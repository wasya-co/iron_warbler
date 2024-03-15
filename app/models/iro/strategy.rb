
class Iro::Strategy
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_strategies'

  field :slug
  validates :slug, presence: true, uniqueness: true

  LONG = 'is-long'
  SHORT = 'is-short'
  field     :long_or_short, type: :string
  validates :long_or_short, presence: true

  field :description

  has_many :positions, class_name: 'Iro::Position', inverse_of: :strategy

  ## multiple strategies per ticker
  # field :ticker
  # validates :ticker, presence: true
  # index({ ticker: 1 })
  # belongs_to :stock, class_name: 'Iro::Stock', inverse_of: :strategies

  KINDS = [ nil,
    'covered-call', 'credit-put-spread', 'credit-call-spread',
    'long-inverted-call-spread',
    'short-inverted-put-spread',
  ]
  field :kind

  field :buffer_above_water, type: :float
  field :next_max_inner_delta, type: :float
  field :next_max_outer_delta, type: :float
  field :next_min_strike, type: :float
  field :threshold_delta, type: :float
  field :threshold_netp, type: :float

  def self.for_ticker ticker
    where( ticker: ticker )
  end

  def to_s
    slug
  end
  def self.list long_or_short = nil
    these = long_or_short ? where( long_or_short: long_or_short ) : all
    [[nil,nil]] + these.map { |ttt| [ ttt.slug, ttt.id ] }
  end
end
