
class Iro::PositionsController < Iro::ApplicationController
  before_action :set_lists

  def create
    pos = @position = Iro::Position.new pos_params
    o_attrs = {
      expires_on: pos.expires_on,
      put_call: pos.put_call,
      stock_id: pos.stock_id,
    }
    pos.inner = Iro::Option.new params[:inner].permit!.merge( o_attrs )
    pos.outer = Iro::Option.new params[:outer].permit!.merge( o_attrs )
    authorize! :create, @position

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

  def edit
    @position = Iro::Position.find params[:id]
    authorize! :edit, @position
  end

  def new
    strategy = Iro::Strategy.find params[:position][:strategy_id]
    @position = Iro::Position.new( params[:position].permit!.merge({
      status: :active,
      inner:  Iro::Option.new,
      outer:  Iro::Option.new,
      stock_id:  strategy.stock_id,
    }) )
    authorize! :new, @posision

    if params[:id]
      old = Iro::Position.find params[:id]
      old = old.attributes
      old.delete :_id
      puts! old, 'old'
      @position = Iro::Position.new old
    end
  end

  def prepare
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position

    @prev  = @position
    @purse = @position.purse
    @stock = @position.stock
    @n_dollars = 100

    ## holiday schedule
    @next_expires_on = @prev.expires_on.to_datetime.next_occurring(:monday).next_occurring(:friday)
    if !@next_expires_on.workday?
      @next_expires_on = Time.previous_business_day( @next_expires_on )
    end

    ## dealing with too many strikes in the chain
    while true
      @nn = ( @position.purse.n_next_positions/2 ).ceil
      upper = Tda::Option.get_quote({
        contractType: @position.put_call,
        strike: @prev.inner.strike + @nn*@stock.options_price_increment,
        expirationDate: @next_expires_on,
        ticker: @stock.ticker,
      })
      if !upper.symbol
        puts! 'too high'
        flash_alert 'too high'
        @purse.n_next_positions = @purse.n_next_positions - 1
        @purse.n_next_positions = 1 if @purse.n_next_positions < 1
        @purse.save!
        next
      end
      lower = Tda::Option.get_quote({
        contractType: @position.put_call,
        strike: @prev.inner.strike - @nn*@stock.options_price_increment,
        expirationDate: @next_expires_on,
        ticker: @stock.ticker,
      })
      if !lower.symbol
        puts! 'too low'
        flash_alert 'too low'
        @purse.n_next_positions = @purse.n_next_positions - 1
        @purse.n_next_positions = 1 if @purse.n_next_positions < 1
        @purse.save!
        next
      end
      break
    end

    self.send("_prepare_#{@position.strategy.kind}")
  end

  ## long debit call spread
  def prepare2
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position

    pos   = @position
    stock = @position.stock

    next_outer = @position.outer || Iro::Option.create({
      stock: stock,
      strike: pos.outer_strike,
      expires_on: pos.expires_on,
      position: pos,
      last: pos.begin_outer_price,
    })

    next_inner = @position.inner || Iro::Option.create({
      stock: stock,
      strike: pos.inner.strike,
      expires_on: pos.expires_on,
      position: pos,
      last: pos.inner.begin_price,
    })

    prev_outer = pos.prev.outer
    prev_inner = pos.prev.inner

    price = pos.prev.outer.last - pos.prev.inner.last + pos.nxt.inner.last - pos.nxt.outer.last

    @query = {
      orderType: "NET_DEBIT",
      session: "NORMAL",
      price: price,
      duration: "DAY",
      orderStrategyType: "SINGLE",
      orderLegCollection: [
        ## @TODO: this is only entering the next position, need to also close out the previous.
        {
          instruction: "BUY_TO_OPEN",
          quantity: q,
          instrument: {
            symbol: outer.symbol,
            assetType: "OPTION",
          },
        },
        {
          instruction: "SELL_TO_OPEN",
          quantity: q,
          instrument: {
            symbol: inner.symbol,
            assetType: "OPTION",
          },
        },
      ],
    }
  end

  ## long debit call spread
  def prepare3
    out = Tda::Option.roll_long_debit_call_spread( position )
  end



  def _prepare_covered_call
    @positions = []
    (-@nn..@nn).each do |idx|
      next_ = Iro::Position.new({
        stock: @stock,
        inner_strike: @prev.inner.strike - idx*@stock.options_price_increment,
        expires_on: @next_expires_on,
        purse: @position.purse,
        strategy: @position.strategy,
        quantity: @position.quantity,
      })
      next_.sync
      next_.begin_inner_price = next_.end_inner_price
      next_.begin_inner_delta = next_.end_inner_delta
      next_.next_gain_loss_amount  = next_.begin_inner_price  - @prev.end_inner_price
      puts! next_, 'next_'
      puts! next_.next_gain_loss_amount, 'amount'
      @positions.push next_
    end
  end

  def _prepare_long_debit_call_spread
    @positions = []
    (-@nn..@nn).each do |idx|
      next_ = Iro::Position.find_or_create_by({
        expires_on:   @next_expires_on,
        inner_strike: @prev.inner.strike - idx*@stock.options_price_increment,
        outer_strike: @prev.outer.strike - idx*@stock.options_price_increment,
        prev_id:      @prev.id,
        purse:        @position.purse,
        quantity:     @position.quantity,
        status:       'prepare',
        stock:        @stock,
        strategy:     @position.strategy,
      })
      pos = next_
      next_.inner ||= Iro::Option.new({
        # begin_price: pos[:begin_inner_price],
        # begin_delta: pos[:begin_inner_delta],
        expires_on: pos[:expires_on],
        inner:      pos,
        put_call:   pos.put_call,
        stock_id:   pos[:stock_id],
        strike:     pos[:inner_strike],
      })
      next_.outer ||= Iro::Option.new({
        # begin_price: pos[:begin_inner_price],
        # begin_delta: pos[:begin_inner_delta],
        expires_on: pos[:expires_on],
        outer:      pos,
        put_call:   pos.put_call,
        stock_id:   pos[:stock_id],
        strike:     pos[:outer_strike],
      })

      next_.sync
      next_.inner.begin_price = next_.inner.end_price
      next_.inner.begin_delta = next_.inner.end_delta

      next_.outer.begin_price = next_.outer.end_price
      next_.outer.begin_delta = next_.outer.end_delta

      next_.next_gain_loss_amount  = @prev.outer.end_price   - @prev.inner.end_price
      next_.next_gain_loss_amount += next_.inner.begin_price - next_.outer.begin_price
      next_.save
      # puts! next_, 'next_'
      # puts! next_.next_gain_loss_amount, 'next_gain_loss_amount'
      @positions.push next_
    end
    @positions = @positions.reverse
  end
  alias_method :_prepare_short_debit_put_spread, :_prepare_long_debit_call_spread


  ## this is auto-driven
  def propose
    @strategy = Iro::Strategy.find params[:strategy_id]
    authorize! :show, @strategy

    @purse = Iro::Purse.find params[:purse_id]

    ## short debit put spread
    outs = Tda::Option.get_quotes({
      contractType:   'PUT',
      expirationDate: '2024-03-28',
      ticker:         @strategy.stock.ticker,
    })
    outs = outs.select do |out|
      out[:bidSize]+out[:askSize] > 0
    end
    outs = outs.select do |out|
      out[:strikePrice] > @strategy.buffer_above_water + @strategy.stock.last
    end
    outs = outs.select do |out|
      out[:strikePrice] > @strategy.next_inner_strike
    end
    outs = outs.select do |out|
      out[:delta] < @strategy.next_inner_delta
    end

    inner = outs[0]
    outs = outs.select do |out|
      out[:strikePrice] >= inner[:strikePrice] + @strategy.next_spread_amount
    end
    outer = outs[0]

    if inner && outer
      next_position = Iro::Position.new({
        status: 'proposed',
        stock: @strategy.stock,
        inner_strike: inner[:strikePrice],
        outer_strike: outer[:strikePrice],
        begin_outer_price: outer[:last],
        begin_outer_delta: outer[:delta],
        begin_inner_price: inner[:last],
        begin_inner_delta: inner[:delta],
        begin_on: Time.now.to_date,
        expires_on: '2024-03-28',
        purse: @purse,
        strategy: @strategy,
        quantity: 1,
      })
      next_position.sync
      next_position.save
    else
      flash_alert 'cannot propose a new one'
    end
    redirect_to request.referrer
  end

  def sync
    @position = pos = Iro::Position.find params[:id]
    authorize! :refresh, @position

    @position.sync
    @position.calc_rollp

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
        put_call: pos.put_call,
        stock_id: pos.stock_id,
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
    params[:position].permit( :purse_id, :status, :stock_id,
      :strategy_id, :expires_on, :quantity, :begin_on,
      :long_or_short,
    )
  end

  def set_lists
    super
    @purses_list     = Iro::Purse.list
    @strategies_list = Iro::Strategy.list(params[:long_or_short])
    @stocks_list     = Iro::Stock.list
  end

end
