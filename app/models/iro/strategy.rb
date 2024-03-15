
class Iro::Strategy
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_strategies'

  field :slug
  validates :slug, presence: true, uniqueness: true

  LONG = 'is_long'
  SHORT = 'is_short'
  field     :long_or_short, type: :string
  validates :long_or_short, presence: true

  field :description

  has_many :positions, class_name: 'Iro::Position', inverse_of: :strategy

  belongs_to :stock, class_name: 'Iro::Stock', inverse_of: :strategies

  KIND_COVERED_CALL = 'covered_call'
  KIND_LONG_DEBIT_CALL_SPREAD = 'long_debit_call_spread'
  KIND_SHORT_DEBIT_PUT_SPREAD = 'long_debit_call_spread'
  KINDS = [ nil,
    KIND_COVERED_CALL,
    KIND_LONG_DEBIT_CALL_SPREAD,
    KIND_SHORT_DEBIT_PUT_SPREAD,
  ]
  field :kind

  def kind_short
    case kind
    when KIND_COVERED_CALL
      'cc'
    when KIND_LONG_DEBIT_CALL_SPREAD
      'long-spread'
    when KIND_SHORT_DEBIT_PUT_SPREAD
      'short-spread'
    else
      '@TODO-zez'
    end
  end

  field :buffer_above_water, type: :float
  field :next_max_inner_delta, type: :float
  field :next_max_outer_delta, type: :float
  field :next_min_strike, type: :float
  field :threshold_delta, type: :float
  field :threshold_netp, type: :float

  def self.for_ticker ticker
    where( ticker: ticker )
  end

  def max_gain_covered_call p
    # return p.begin_inner_price
    p.begin_inner_price * 100 - 0.66
  end
  def max_gain_long_debit_call_spread p
    ## 100 * disalloed for gameui
    ( p.inner_strike - p.outer_strike - p.begin_outer_price + p.begin_inner_price ) # - 2*0.66
  end
  def max_gain_short_debit_put_spread p
    ## 100 * disalloed for gameui
    ( p.outer_strike - p.inner_strike - p.begin_outer_price + p.begin_inner_price ) # - 2*0.66
  end

  def max_loss_covered_call p
    return 'inf'
  end
  def max_loss_long_debit_call_spread p
    out = 100 * ( p.outer_strike - p.inner_strike )
  end
  def max_loss_short_debit_put_spread p
    out = -100 * ( p.outer_strike - p.inner_strike )
  end

  def net_amount_covered_call p
    ( p.begin_inner_price - p.end_inner_price ) * 100
  end
  def net_amount_long_debit_call_spread p
    outer = p.end_outer_price - p.begin_outer_price
    inner = p.begin_inner_price - p.end_inner_price
    out = ( outer + inner ) * 100
  end
  alias_method :net_amount_short_debit_put_spread, :net_amount_long_debit_call_spread


  def net_amount_long_debit_call_spread p
    outer = p.end_outer_price - p.begin_outer_price
    inner = p.begin_inner_price - p.end_inner_price
    out = ( outer + inner ) * 100
  end



  def to_s
    slug
  end
  def self.list long_or_short = nil
    these = long_or_short ? where( long_or_short: long_or_short ) : all
    [[nil,nil]] + these.map { |ttt| [ ttt.slug, ttt.id ] }
  end
end
