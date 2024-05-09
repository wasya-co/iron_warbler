
class Iro::Strategy
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'iro_strategies'

  field :slug
  validates :slug, presence: true, uniqueness: true

  field :description

  LONG  = 'is_long'
  SHORT = 'is_short'
  field     :long_or_short, type: :string
  validates :long_or_short, presence: true


  has_many :positions,     class_name: 'Iro::Position', inverse_of: :strategy
  has_one  :next_position, class_name: 'Iro::Position', inverse_of: :next_strategy
  belongs_to :stock, class_name: 'Iro::Stock', inverse_of: :strategies
  has_and_belongs_to_many :purses, class_name: 'Iro::Purse', inverse_of: :strategies

  KIND_COVERED_CALL             = 'covered_call'
  KIND_IRON_CONDOR              = 'iron_condor'
  KIND_LONG_CREDIT_PUT_SPREAD   = 'long_credit_put_spread'
  KIND_LONG_DEBIT_CALL_SPREAD   = 'long_debit_call_spread'
  KIND_SHORT_CREDIT_CALL_SPREAD = 'short_credit_call_spread'
  KIND_SHORT_DEBIT_PUT_SPREAD   = 'short_debit_put_spread'
  KINDS = [ nil,
    KIND_COVERED_CALL,
    KIND_IRON_CONDOR,
    KIND_LONG_CREDIT_PUT_SPREAD,
    KIND_LONG_DEBIT_CALL_SPREAD,
    KIND_SHORT_CREDIT_CALL_SPREAD,
    KIND_SHORT_DEBIT_PUT_SPREAD,
  ]
  field :kind

  def put_call
    case kind
    when Iro::Strategy::KIND_LONG_DEBIT_CALL_SPREAD
      put_call = 'CALL'
    when Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD
      put_call = 'CALL'
    when Iro::Strategy::KIND_SHORT_DEBIT_PUT_SPREAD
      put_call = 'PUT'
    when Iro::Strategy::KIND_COVERED_CALL
      put_call = 'CALL'
    end
  end

  field :threshold_buffer_above_water, type: :float
  field :threshold_delta,              type: :float
  field :threshold_netp,               type: :float
  field :threshold_dte,                type: :integer, default: 1

  field :next_inner_delta,        type: :float
  field :next_inner_strike,       type: :float
  field :next_outer_delta,        type: :float
  field :next_outer_strike,       type: :float
  field :next_spread_amount,      type: :float # e.g. $20 for a $2000 NVDA spread
  field :next_buffer_above_water, type: :float






  def begin_delta_covered_call p
    p.inner.begin_delta
  end
  def begin_delta_long_debit_call_spread p
    p.outer.begin_delta - p.inner.begin_delta
  end
  alias_method :begin_delta_short_debit_put_spread,   :begin_delta_long_debit_call_spread
  alias_method :begin_delta_short_credit_call_spread, :begin_delta_long_debit_call_spread


  def breakeven_covered_call p
    p.inner.strike + p.inner.begin_price
  end
  def breakeven_long_debit_call_spread p
    p.inner.strike - p.max_gain
  end
  alias_method :breakeven_short_debit_put_spread, :breakeven_long_debit_call_spread


  def end_delta_covered_call p
    p.inner.end_delta
  end
  def end_delta_long_debit_call_spread p
    p.outer.end_delta - p.inner.end_delta
  end
  alias_method :end_delta_short_debit_put_spread,   :end_delta_long_debit_call_spread
  alias_method :end_delta_short_credit_call_spread, :end_delta_long_debit_call_spread


  def max_gain_covered_call p
    p.inner.begin_price * 100 - 0.66 # @TODO: is this *100 really?
  end
  def max_gain_long_debit_call_spread p
    ## 100 * disallowed for gameui
    ( p.inner.strike - p.outer.strike - p.outer.begin_price + p.inner.begin_price ) # - 2*0.66
  end
  def max_gain_short_credit_call_spread p
    p.inner.begin_price - p.outer.begin_price
  end
  def max_gain_short_debit_put_spread p
    ## 100 * disallowed for gameui
    ( p.outer.strike - p.inner.strike - p.outer.begin_price + p.inner.begin_price ) # - 2*0.66
  end


  def max_loss_covered_call p
    p.inner.begin_price*10 # just suppose 10,000%
  end
  def max_loss_long_debit_call_spread p
    out = p.outer.strike - p.inner.strike
  end
  def max_loss_short_debit_put_spread p # different
    out = p.inner.strike - p.outer.strike
  end
  def max_loss_short_credit_call_spread p
    out = p.outer.strike - p.inner.strike
  end


  def net_amount_covered_call p
    ( p.inner.begin_price - p.inner.end_price )
  end
  def net_amount_long_debit_call_spread p
    outer = p.outer.end_price   - p.outer.begin_price
    inner = p.inner.begin_price - p.inner.end_price
    out = ( outer + inner )
  end
  alias_method :net_amount_short_credit_call_spread , :net_amount_long_debit_call_spread
  alias_method :net_amount_short_debit_put_spread,    :net_amount_long_debit_call_spread


  ## 2024-05-09 @TODO
  def next_inner_strike_on expires_on
    outs = Tda::Option.get_quotes({
      contractType: put_call,
      expirationDate: expires_on,
      ticker: stock.ticker,
    })
  end



  ##
  ## decisions
  ##

  def calc_rollp_covered_call p

    if ( p.expires_on.to_date - Time.now.to_date ).to_i < 1
      return [ 0.99, '0 DTE, must exit' ]
    end

    if ( stock.last - buffer_above_water ) < p.inner.strike
      return [ 0.98, "Last #{'%.2f' % stock.last} is " +
          "#{'%.2f' % [p.inner.strike + buffer_above_water - stock.last]} " +
          "below #{'%.2f' % [p.inner.strike + buffer_above_water]} water" ]
    end

    if p.inner.end_delta < threshold_delta
      return [ 0.61, "Delta #{p.inner.end_delta} is lower than #{threshold_delta} threshold." ]
    end

    if 1 - p.inner.end_price/p.inner.begin_price > threshold_netp
      return [ 0.51, "made enough #{'%.02f' % [(1.0 - p.inner.end_price/p.inner.begin_price )*100]}% profit." ]
    end

    return [ 0.33, '-' ]
  end

  ## @TODO
  def calc_rollp_long_debit_call_spread p

    if ( p.expires_on.to_date - Time.now.to_date ).to_i < 1
      return [ 0.99, '0 DTE, must exit' ]
    end
    if ( p.expires_on.to_date - Time.now.to_date ).to_i < 2
      return [ 0.99, '1 DTE, must exit' ]
    end

    if ( stock.last - buffer_above_water ) < p.inner.strike
      return [ 0.95, "Last #{'%.2f' % stock.last} is " +
          "#{'%.2f' % [stock.last - p.inner.strike - buffer_above_water]} " +
          "below #{'%.2f' % [p.inner.strike + buffer_above_water]} water" ]
    end

    if p.inner.end_delta < threshold_delta
      return [ 0.79, "Delta #{p.inner.end_delta} is lower than #{threshold_delta} threshold." ]
    end

    if 1 - p.inner.end_price/p.inner.begin_price > threshold_netp
      return [ 0.51, "made enough #{'%.02f' % [(1.0 - p.inner.end_price/p.inner.begin_price )*100]}% profit^" ]
    end

    return [ 0.33, '-' ]
  end

  ## @TODO
  def calc_rollp_short_debit_put_spread p

    if ( p.expires_on.to_date - Time.now.to_date ).to_i <= min_dte
      return [ 0.99, "< #{min_dte}DTE, must exit" ]
    end

    if stock.last + buffer_above_water > p.inner.strike
      return [ 0.98, "Last #{'%.2f' % stock.last} is " +
          "#{'%.2f' % [stock.last + buffer_above_water - p.inner.strike]} " +
          "above #{'%.2f' % [p.inner.strike - buffer_above_water]} water" ]
    end

    if p.inner.end_delta.abs < threshold_delta.abs
      return [ 0.79, "Delta #{p.inner.end_delta} is lower than #{threshold_delta} threshold." ]
    end

    if p.net_percent > threshold_netp
      return [ 0.51, "made enough #{'%.0f' % [p.net_percent*100]}% > #{"%.2f" % [threshold_netp*100]}% profit," ]
    end

    return [ 0.33, '-' ]
  end


  ## scopes

  def self.for_ticker ticker
    where( ticker: ticker )
  end


  def to_s
    slug
  end
  def self.list long_or_short = nil
    these = long_or_short ? where( long_or_short: long_or_short ) : all
    [[nil,nil]] + these.map { |ttt| [ ttt, ttt.id ] }
  end
end

