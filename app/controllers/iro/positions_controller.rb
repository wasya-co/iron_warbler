
class Iro::PositionsController < Iro::ApplicationController
  before_action :set_lists

  def new
    @position = Iro::Position.new
    authorize! :new, @posision

    if params[:id]
      old = Iro::Position.find params[:id]
      old = old.attributes
      old.delete :_id
      puts! old, 'old'
      @position = Iro::Position.new old
    end
    if params[:purse_id]
      @position.purse_id = params[:purse_id]
    end

  end

  def create
    @position = Iro::Position.new params[:position].permit!
    authorize! :create, @position

    @position.sync

    if @position.save
      flash_notice @position
      redirect_to controller: :purses, action: :show, id: @position.purse_id.to_s
    else
      flash_alert @position
      redirect_to request.referrer
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
      out[:strikePrice] >= inner[:strikePrice] + @strategy.spread_amount
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

  def refresh
    @position = pos = Iro::Position.find params[:id]
    authorize! :refresh, @position

    @position.sync
    @position.calc_rollp

    redirect_to request.referrer || purse_path( @position.purse )
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
        contractType: 'CALL',
        strike: @prev.inner_strike + @nn*@stock.options_price_increment,
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
        contractType: 'CALL',
        strike: @prev.inner_strike - @nn*@stock.options_price_increment,
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

  def _prepare_covered_call
    @positions = []
    (-@nn..@nn).each do |idx|
      next_ = Iro::Position.new({
        stock: @stock,
        inner_strike: @prev.inner_strike - idx*@stock.options_price_increment,
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
      next_ = Iro::Position.new({
        stock: @stock,
        inner_strike: @prev.inner_strike - idx*@stock.options_price_increment,
        outer_strike: @prev.outer_strike - idx*@stock.options_price_increment,
        expires_on:   @next_expires_on,
        purse:        @position.purse,
        strategy:     @position.strategy,
        quantity:     @position.quantity,
      })
      next_.sync
      next_.begin_inner_price = next_.end_inner_price
      next_.begin_inner_delta = next_.end_inner_delta

      next_.begin_outer_price = next_.end_outer_price
      next_.begin_outer_delta = next_.end_outer_delta
      next_.next_gain_loss_amount  = @prev.end_outer_price   - @prev.end_inner_price
      next_.next_gain_loss_amount += next_.begin_inner_price - next_.begin_outer_price
      puts! next_, 'next_'
      puts! next_.next_gain_loss_amount, 'next_gain_loss_amount'
      @positions.push next_
    end
    @positions = @positions.reverse
  end

  def _prepare_short_debit_put_spread
    @positions = []
    (-@nn..@nn).each do |idx|
      next_ = Iro::Position.new({
        stock: @stock,
        inner_strike: @prev.inner_strike - idx*@stock.options_price_increment,
        outer_strike: @prev.outer_strike - idx*@stock.options_price_increment,
        expires_on:   @next_expires_on,
        purse:        @position.purse,
        strategy:     @position.strategy,
        quantity:     @position.quantity,
      })
      next_.sync
      next_.begin_inner_price = next_.end_inner_price
      next_.begin_inner_delta = next_.end_inner_delta

      next_.begin_outer_price = next_.end_outer_price
      next_.begin_outer_delta = next_.end_outer_delta
      next_.next_gain_loss_amount  = @prev.end_outer_price - @prev.end_inner_price
      next_.next_gain_loss_amount += next_.begin_inner_price - next_.begin_outer_price
      puts! next_, 'next_'
      puts! next_.next_gain_loss_amount, 'next_gain_loss_amount'
      @positions.push next_
    end
  end

  def update
    @position = Iro::Position.find params[:id]
    authorize! :update, @position

    if @position.update params[:position].permit!
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

  def set_lists
    super

    @purses_list     = Iro::Purse.list
    @strategies_list = Iro::Strategy.list(params[:long_or_short])
    @stocks_list     = Iro::Stock.list
  end

end
