
class Iro::Position
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_positions'

  attr_accessor :gain_loss_amount

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
  # validates :outer_strike, presence: true

  field     :inner_strike, type: :float
  validates :inner_strike, presence: true

  field :expires_on
  validates :expires_on, presence: true

  field :quantity, type: :integer
  validates :quantity, presence: true
  def q; quantity; end

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

  def breakeven
    strategy.breakeven(self)
  end

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

  def net_percent
    net_amount / max_gain
  end
  def net_amount # each
    strategy.send("net_amount_#{strategy.kind}", self)
  end
  def max_gain # each
    strategy.send("max_gain_#{strategy.kind}", self)
  end
  def max_loss # each
    strategy.send("max_loss_#{strategy.kind}", self)
  end


  field :next_delta, type: :float
  field :next_outcome, type: :float
  field :next_symbol
  field :next_mark
  field :next_reasons, type: :array, default: []
  field :rollp, type: :float


  ## covered call
  # def sync
  #   puts! [ inner_strike, expires_on, stock.ticker ], 'init sync'
  #   out = Tda::Option.get_quote({
  #     contractType: 'CALL',
  #     strike: inner_strike,
  #     expirationDate: expires_on,
  #     ticker: stock.ticker,
  #   })
  #   puts! out, 'sync'
  #   self.end_inner_price = ( out.bid + out.ask ) / 2
  #   self.end_inner_delta = out.delta
  # end

  ## long call spread
  def sync
    puts! [
      [ inner_strike, expires_on, stock.ticker ],
      [ outer_strike, expires_on, stock.ticker ],
     ], 'init sync inner, outer'
    inner = Tda::Option.get_quote({
      contractType: 'CALL',
      strike: inner_strike,
      expirationDate: expires_on,
      ticker: stock.ticker,
    })
    outer = Tda::Option.get_quote({
      contractType: 'CALL',
      strike: outer_strike,
      expirationDate: expires_on,
      ticker: stock.ticker,
    })
    puts! [inner, outer], 'sync inner, outer'
    self.end_outer_price = ( outer.bid + outer.ask ) / 2
    self.end_outer_delta = outer.delta

    self.end_inner_price = ( inner.bid + inner.ask ) / 2
    self.end_inner_delta = inner.delta
  end

  ##
  ## decisions
  ##

  def calc_rollp
    self.next_reasons = []
    self.next_symbol = nil
    self.next_delta = nil

    out = strategy.send( "calc_rollp_#{strategy.kind}", self )

    self.rollp = out[0]
    self.next_reasons.push out[1]
    save

    # update({
    #   next_delta:   next_position[:delta],
    #   next_outcome: next_position[:mark] - end_price,
    #   next_symbol:  next_position[:symbol],
    #   next_mark:    next_position[:mark],
    #   should_rollp: out,
    #   # status:       Iro::Position::STATE_PROPOSED,
    # })
  end


  ## expires_on = cc.expires_on ; nil
  def can_roll?
    ## only if less than 7 days left
    ( expires_on.to_date - Time.now.to_date ).to_i < 7
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

  def to_s
    out = "#{stock} (#{q}) #{expires_on.to_datetime.strftime('%b %d')} #{strategy.kind_short} ["
    if outer_strike
      out = out + "$#{outer_strike}->"
    end
    out = out + "$#{inner_strike}] "
    return out
  end
end
