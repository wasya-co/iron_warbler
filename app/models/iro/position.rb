
class Iro::Position
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_positions'

  STATUS_ACTIVE   = 'active'
  STATUS_PROPOSED = 'proposed'
  STATUSES = [ nil, 'active', 'inactive', 'proposed' ]
  field :status
  validates :status, presence: true
  scope :active, ->{ where( status: 'active' ) }

  belongs_to :purse,    class_name: 'Iro::Purse',    inverse_of: :positions
  index({ purse_id: 1, ticker: 1 })

  belongs_to :stock,   class_name: 'Iro::Stock',    inverse_of: :positions
  def ticker
    stock&.ticker || '-'
  end

  belongs_to :strategy, class_name: 'Iro::Strategy', inverse_of: :positions

  # field :ticker
  # validates :ticker, presence: true

  field     :outer_strike, type: :float
  validates :outer_strike, presence: true

  field     :inner_strike, type: :float
  validates :inner_strike, presence: true

  field :expires_on
  validates :expires_on, presence: true

  field :quantity, type: :integer
  validates :quantity, presence: true

  field :begin_on
  field :begin_outer_price, type: :float
  field :begin_outer_delta, type: :float

  field :begin_inner_price, type: :float
  field :begin_inner_delta, type: :float

  field :end_on
  field :end_outer_price, type: :float
  field :end_outer_delta, type: :float

  field :end_inner_price, type: :float
  field :end_inner_delta, type: :float

  field :net_amount
  field :net_percent

  def current_underlying_strike
    Iro::Stock.find_by( ticker: ticker ).last
  end

  def refresh
    out = Tda::Option.get_quote({
      contractType:   'CALL',
      strike:         strike,
      expirationDate: expires_on,
      ticker:         ticker,
    })
    update({
      end_delta: out[:delta],
      end_price: out[:last],
    })
    print '_'
  end

  def net_amount # total
    outer = 0 - begin_outer_price + end_outer_price
    inner = begin_inner_price - end_inner_price
    return ( outer + inner ) * 100 * quantity
  end
  def max_gain # total
    100 * ( begin_outer_price - begin_inner_price ) * quantity
  end
  def max_loss
    100 * ( outer_strike - inner_strike ) * quantity
  end


  field :next_delta, type: :float
  field :next_outcome, type: :float
  field :next_symbol
  field :next_mark
  field :next_reasons, type: :array, default: []
  field :should_rollp, type: :float

  ##
  ## decisions
  ##

  def should_roll?
    puts! 'shold_roll?'

    update({
      next_reasons: [],
      next_symbol: nil,
      next_delta: nil,
    })

    if must_roll?
      out = 1.0
    elsif can_roll?

      if end_delta < strategy.threshold_delta
        next_reasons.push "delta is lower than threshold"
        out = 0.91
      elsif 1 - end_outer_price/begin_outer_price > strategy.threshold_netp
        next_reasons.push "made enough percent profit (dubious)"
        out = 0.61
      else
        next_reasons.push "neutral"
        out = 0.33
      end

    else
      out = 0.0
    end

    update({
      next_delta:   next_position[:delta],
      next_outcome: next_position[:mark] - end_price,
      next_symbol:  next_position[:symbol],
      next_mark:    next_position[:mark],
      should_rollp: out,
      # status:       Iro::Position::STATE_PROPOSED,
    })

    puts! next_reasons, 'next_reasons'
    puts! out, 'out'
    return out > 0.5
  end


  ## expires_on = cc.expires_on ; nil
  def can_roll?
    ## only if less than 7 days left
    ( expires_on.to_date - Time.now.to_date ).to_i < 7
  end

  ## If I'm near below water
  ##
  ## expires_on = cc.expires_on ; strategy = cc.strategy ; strike = cc.strike ; nil
  def must_roll?
    if ( current_underlying_strike + strategy.buffer_above_water ) > strike
      return true
    end
    ## @TODO: This one should not happen, I should log appropriately. _vp_ 2023-03-19
    if ( expires_on.to_date - Time.now.to_date ).to_i < 1
      return true
    end
  end

  ## strike = cc.strike ; strategy = cc.strategy ; nil
  def near_below_water?
    strike < current_underlying_strike + strategy.buffer_above_water
  end



  ## 2023-03-18 _vp_ Continue.
  ## 2023-03-19 _vp_ Continue.
  ## 2023-08-05 _vp_ an Important method
  ##
  ## expires_on = cc.expires_on ; strategy = cc.strategy ; ticker = cc.ticker ; end_price = cc.end_price ; next_expires_on = cc.next_expires_on ; nil
  ##
  ## out.map { |p| [ p[:strikePrice], p[:delta] ] }
  ##
  def next_position
    return @next_position if @next_position
    return {} if ![ STATUS_ACTIVE, STATUS_PROPOSED ].include?( status )

    ## 7 days ahead - not configurable so far
    out = Tda::Option.get_quotes({
      ticker: ticker,
      expirationDate: next_expires_on,
      contractType: 'CALL',
    })

    ## above_water
    if strategy.buffer_above_water.present?
      out = out.select do |i|
        i[:strikePrice] > current_underlying_strike + strategy.buffer_above_water
      end
      # next_reasons.push "buffer_above_water above #{current_underlying_strike + strategy.buffer_above_water}"
    end

    if near_below_water?
      msg = "Panic! climb at a loss. Skip the rest of the calculation."
      next_reasons.push msg
      ## @TODO: if not enough money in the purse, cannot roll? 2023-03-19

      # byebug

      ## Take a small loss here.
      prev = nil
      out.each_with_index do |i, idx|
        next if idx == 0
        if i[:last] < end_price
          prev ||= i
        end
      end
      out = [ prev ]

    else
      ## Normal flow, making money.
      ## @TODO: test! _vp_ 2023-03-19

      ## next_min_strike
      if strategy.next_min_strike.present?
        out = out.select do |i|
          i[:strikePrice] >= strategy.next_min_strike
        end
        # next_reasons.push "next_min_strike above #{strategy.next_min_strike}"
      end
      # json_puts! out.map { |p| [p[:delta], p[:symbol]] }, 'next_min_strike'

      ## max_delta
      if strategy.next_max_delta.present?
        out = out.select do |i|
          i[:delta] = 0.0 if i[:delta] == "NaN"
          i[:delta] <= strategy.next_max_delta
        end
        # next_reasons.push "next_max_delta below #{strategy.next_max_delta}"
      end
      # json_puts! out.map { |p| [p[:delta], p[:symbol]] }, 'next_max_delta'
    end

    @next_position = out[0] || {}
  end

  ## @TODO: Test this. _vp_ 2023-04-01
  def next_expires_on
    out = expires_on.to_time + 7.days
    while !out.friday?
      out = out + 1.day
    end
    while !out.workday?
      out = out - 1.day
    end
    return out
  end

end
