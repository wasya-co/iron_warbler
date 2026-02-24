
class Iro::PositionsController < Iro::ApplicationController
  before_action :set_lists

  def create
    pos = @position = Iro::Position.new pos_params
    authorize! :create, @position

    o_attrs = {
      expires_on: pos.expires_on,
      put_call: pos.put_call, # I need this. _vp_ 2024-04-26
      stock_id: pos.stock_id,
    }
    pos.inner = Iro::Option.new params[:inner].permit!.merge( o_attrs )
    if [ Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD, Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD ].include?( pos.strategy.kind )
      pos.outer = Iro::Option.new params[:outer].permit!.merge( o_attrs )
    end

    if @position.save
      flash_notice @position
      redirect_to controller: :purses, action: :show, id: @position.purse_id.to_s
    else
      flash_alert @position
      render action: :new # redirect_to request.referrer
    end
  end

  def destroy
    @position = Iro::Position.find params[:id]
    authorize! :destroy, @position
    @position.delete
    flash_notice "Probably ok"
    redirect_to request.referrer
  end

  def destroy_multi
    positions = Iro::Position.find params[:positions_xmulti].split(',')
    authorize! :destroy, Iro::Position

    puts! positions, 'positions'
    flags = positions.map { |p| p.delete }
    flash_notice "Probably ok: #{flags}"
    redirect_to request.referrer
  end

  def edit
    @position = Iro::Position.find params[:id]
    authorize! :edit, @position
  end

  def new
    strategy    = Iro::Strategy.find params[:position][:strategy_id]

    @position   = strategy.next_position
    @position ||= Iro::Position.new( params[:position].permit!.merge({
      put_call: strategy.put_call,
      status:   Iro::Position::STATUS_PROPOSED,
      # inner:    Iro::Option.new,
      # outer:    Iro::Option.new,
      stock_id: strategy.stock_id,
    }) )
    authorize! :new, @position

    ## 2026-02-24 why is this here?
    # @position.calc_nxt

    # if params[:id]
    #   old = Iro::Position.find params[:id]
    #   old = old.attributes
    #   old.delete :_id
    #   puts! old, 'old'
    #   @position = Iro::Position.new old
    # end
  end

  ## 2025-10-14 long_credit_put_spread
  ## 2026-02-21 short_credit_call_spread
  def prepare
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position

    @prev      = @position
    @purse     = @position.purse
    @stock     = @position.stock
    @nn        = @position.purse.n_next_positions
    @n_dollars = 100 ## used in the view, but the name is unclear

    self.send("_prepare_#{@position.strategy.kind}")
  end

  ## long debit call spread
  def prepare2
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position

    pos   = @position
    stock = @position.stock

    @query = {
      orderType: price > 0 ? "NET_CREDIT" : "NET_DEBIT",
      session: "NORMAL",
      price: price,
      duration: "DAY",
      orderStrategyType: "SINGLE",
      orderLegCollection: [
        ## close
        {
          instruction: "BUY_TO_CLOSE",
          quantity: pos.q,
          instrument: {
            symbol: pos.autoprev.inner.symbol,
            assetType: "OPTION",
          },
        },
        {
          instruction: "SELL_TO_CLOSE",
          quantity: pos.q,
          instrument: {
            symbol: pos.autoprev.outer.symbol,
            assetType: "OPTION",
          },
        },

        ## open
        {
          instruction: "BUY_TO_OPEN",
          quantity: pos.q,
          instrument: {
            symbol: pos.outer.symbol,
            assetType: "OPTION",
          },
        },
        {
          instruction: "SELL_TO_OPEN",
          quantity: pos.q,
          instrument: {
            symbol: pos.inner.symbol,
            assetType: "OPTION",
          },
        },
      ],
    }
    puts! @query, '@query'
  end

  ## long debit call spread
  def prepare3
    pos = @position = Iro::Position.find params[:id]
    authorize! :place_order, @position

    # out = Tda::Option.roll_long_debit_call_spread( position )

    ## @TODO: it's pending here, the order has not been placed.

    flags = []

    flags.push pos.prev.update({ status: Iro::Position::STATUS_CLOSED })
    flags.push pos.update({ status: Iro::Position::STATUS_ACTIVE })
    flags.push pos.purse.update({
      available_amount: pos.purse.available_amount + price + pos.q*100,
    })

    flash_notice flags
    redirect_to controller: :purses, action: :show, template: :gameui, id: pos.purse_id
  end



  def _prepare_covered_call
    @positions = []
    (-@nn..@nn).each do |idx|
      next_ = Iro::Position.new({
        stock:        @stock,
        inner_strike: @prev.inner.strike - idx*@stock.options_price_increment,
        expires_on:   @prev.next_expires_on,
        purse:        @position.purse,
        strategy:     @position.strategy,
        quantity:     @position.quantity,
      })
      # next_.sync
      next_.begin_inner_price = next_.end_inner_price
      next_.begin_inner_delta = next_.end_inner_delta
      next_.next_gain_loss_amount  = next_.begin_inner_price  - @prev.end_inner_price
      @positions.push next_
    end
  end

  ## 2025-10-14 _TODO: move to a model?
  ## 2026-02-18 continue
  def _prepare_long_credit_put_spread
    ## get quotes for next expires_at
    quotes_params = { contractType: @position.put_call, ticker: @stock.ticker, expirationDate: @prev.next_expires_on }
    puts! quotes_params, 'quotes_params'
    quotes = Tda::Option.get_quotes(quotes_params)

    # strike_price = @position.inner.strike
    # strike_prices = quotes.map { |q| q[:strikePrice] }
    # index = strike_prices.index(strike_price)

    @positions = []
    (-@nn..@nn).each do |idx|
      outer_strike = @prev.outer.strike - idx*@stock.options_price_increment
      inner_strike = @prev.inner.strike - idx*@stock.options_price_increment
      puts! [idx, outer_strike, inner_strike], '[idx, outer_strike, inner_strike]'

      next_ = Iro::Position.where({
        prev_id:      @prev.id,
        expires_on:   @prev.next_expires_on,
        inner_strike: inner_strike,
        outer_strike: outer_strike,
      }).first
      if !next_
        next_ = Iro::Position.create({
          prev_id:      @prev.id,
          expires_on:   @prev.next_expires_on,
          inner_strike: inner_strike,
          outer_strike: outer_strike,

          purse:        @position.purse,
          quantity:     @position.quantity,
          status:       'prepare',
          stock:        @stock,
          strategy:     @position.strategy,
        })
        pos = next_
        next_.inner ||= Iro::Option.create({
          # begin_price: pos[:begin_inner_price],
          # begin_delta: pos[:begin_inner_delta],
          expires_on:   pos[:expires_on],
          pos_of_inner: pos,
          put_call:     pos.put_call,
          stock_id:     pos[:stock_id],
          strike:       pos[:inner_strike],
        })
        next_.outer ||= Iro::Option.create({
          # begin_price: pos[:begin_inner_price],
          # begin_delta: pos[:begin_inner_delta],
          expires_on:   pos[:expires_on],
          pos_of_outer: pos,
          put_call:     pos.put_call,
          stock_id:     pos[:stock_id],
          strike:       pos[:outer_strike],
        })
      end

      quotes.map do |quote|
        if quote[:strikePrice] == next_.inner.strike
          price = ( quote[:bid] + quote[:ask] )/2
          next_.inner.begin_price = price
          next_.inner.end_price   = price
          next_.inner.begin_delta = quote[:delta]
          next_.inner.end_delta   = quote[:delta]
          next_.inner.save
        end
        if quote[:strikePrice] == next_.outer.strike
          price = ( quote[:bid] + quote[:ask] )/2
          next_.outer.begin_price = price
          next_.outer.end_price   = price
          next_.outer.begin_delta = quote[:delta]
          next_.outer.end_delta   = quote[:delta]
          next_.outer.save
        end
      end

      next_.next_gain_loss_amount  = @prev.outer.end_price   - @prev.inner.end_price
      next_.next_gain_loss_amount += next_.inner.begin_price - next_.outer.begin_price
      next_.save
      @positions.push next_
    end
  end

  ## 2026-02-21 its not working
  def _prepare_short_credit_call_spread
    quotes_params = { contractType: @position.put_call, ticker: @stock.ticker, expirationDate: @prev.next_expires_on }
    puts! quotes_params, 'quotes_params'
    quotes = Tda::Option.get_quotes(quotes_params)

    @positions = []
    (-@nn..@nn).each do |idx|
      inner_strike = @prev.inner.strike - idx*@stock.options_price_increment
      outer_strike = @prev.outer.strike - idx*@stock.options_price_increment
      puts! [idx, inner_strike, outer_strike], '[idx, inner_strike, outer_strike]'

      next_ = Iro::Position.where({
        prev_id:      @prev.id,
        expires_on:   @prev.next_expires_on,
        inner_strike: inner_strike,
        outer_strike: outer_strike,
      }).first
      if !next_
        next_ = Iro::Position.create({
          prev_id:      @prev.id,
          expires_on:   @prev.next_expires_on,
          inner_strike: inner_strike,
          outer_strike: outer_strike,

          purse:        @position.purse,
          quantity:     @position.quantity,
          status:       'prepare',
          stock:        @stock,
          strategy:     @position.strategy,
        })
        pos = next_
        next_.inner ||= Iro::Option.create({
          expires_on:   pos[:expires_on],
          pos_of_inner: pos,
          put_call:     pos.put_call,
          stock_id:     pos[:stock_id],
          strike:       pos[:inner_strike],
        })
        next_.outer ||= Iro::Option.create({
          expires_on:   pos[:expires_on],
          pos_of_outer: pos,
          put_call:     pos.put_call,
          stock_id:     pos[:stock_id],
          strike:       pos[:outer_strike],
        })
      end

      quotes.map do |quote|
        if quote[:strikePrice] == next_.inner.strike
          price = ( quote[:bid] + quote[:ask] )/2
          next_.inner.begin_price = price
          next_.inner.end_price   = price
          next_.inner.begin_delta = quote[:delta]
          next_.inner.end_delta   = quote[:delta]
          next_.inner.save
        end
        if quote[:strikePrice] == next_.outer.strike
          price = ( quote[:bid] + quote[:ask] )/2
          next_.outer.begin_price = price
          next_.outer.end_price   = price
          next_.outer.begin_delta = quote[:delta]
          next_.outer.end_delta   = quote[:delta]
          next_.outer.save
        end
      end

      next_.next_gain_loss_amount  = @prev.outer.end_price   - @prev.inner.end_price
      next_.next_gain_loss_amount += next_.inner.begin_price - next_.outer.begin_price
      next_.save
      @positions.push next_
    end
    @positions = @positions.reverse
  end



  def sync
    @position = Iro::Position.find params[:id]
    authorize! :refresh, @position

    @position.sync
    @position.calc_rollp
    ## _TODO: this craps out in a bad way. 2026-02-18
    # if @position.rollp > 0.5
    #   @position.calc_nxt
    # end

    redirect_to request.referrer || purse_path( @position.purse )
  end

  ##
  ## only updates some attributes
  ##
  def update
    pos = @position = Iro::Position.find params[:id]
    authorize! :update, @position

    if @position.update pos_params
      o_attrs = {
        expires_on: pos.expires_on,
      }
      pos.inner.update params[:inner].permit!.merge( o_attrs )
      pos.outer.update params[:outer].permit!.merge( o_attrs )

      flash_notice @position
      redirect_to controller: :purses, action: :show, id: @position.purse_id.to_s
    else
      flash_alert @position
      redirect_to request.referrer
    end
  end



  ##
  ## private
  ##
  private

  def pos_params
    params[:position].permit( :begin_on,
      :expires_on,
      :long_or_short,
      :purse_id, :put_call,
      :quantity,
      :status, :stock_id, :strategy_id,
    )
  end

  def price
    pos = @position
    out = pos.autoprev.outer.end_price - pos.autoprev.inner.end_price + pos.inner.begin_price - pos.outer.begin_price
    return out
  end


  def set_lists
    super
    @purses_list     = Iro::Purse.list
    @strategies_list = Iro::Strategy.list(params[:long_or_short])
    @stocks_list     = Iro::Stock.list
  end

end
