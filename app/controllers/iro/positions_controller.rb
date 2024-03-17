
class Iro::PositionsController < Iro::ApplicationController
  before_action :set_lists

  def new
    @position = Iro::Position.new purse_id: params[:purse_id]
    authorize! :new, @posision
  end

  def create
    @position = Iro::Position.new params[:position].permit!
    authorize! :create, @position

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

  def refresh
    @position = pos = Iro::Position.find params[:id]
    authorize! :refresh, @position

    @position.sync
    @position.calc_rollp

    redirect_to request.referrer || purse_path( @position.purse )
  end

  def roll
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
      puts! @nn, 'nn'
      upper = Tda::Option.get_quote({
        contractType: 'CALL',
        strike: @prev.inner_strike + @nn*@stock.options_price_increment,
        expirationDate: @next_expires_on,
        ticker: @stock.ticker,
      })
      puts! upper, 'upper'
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
      puts! lower, 'lower'
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

    self.send("_roll_#{@position.strategy.kind}")
  end

  def _roll_covered_call
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
      # byebug
      next_.gain_loss_amount  = next_.begin_inner_price  - @prev.end_inner_price
      puts! next_, 'next_'
      puts! next_.gain_loss_amount, 'amount'
      @positions.push next_
    end
  end

  def _roll_long_debit_call_spread
    @positions = []
    (-@nn..@nn).each do |idx|
      next_ = Iro::Position.new({
        stock: @stock,
        inner_strike: @prev.inner_strike - idx*@stock.options_price_increment,
        outer_strike: @prev.outer_strike - idx*@stock.options_price_increment,
        expires_on:   @next_expires_on,
        purse:       @position.purse,
        strategy:    @position.strategy,
        quantity:    @position.quantity,
      })
      next_.sync
      next_.begin_inner_price = next_.end_inner_price
      next_.begin_inner_delta = next_.end_inner_delta

      next_.begin_outer_price = next_.end_outer_price
      next_.begin_outer_delta = next_.end_outer_delta
      next_.gain_loss_amount  = @prev.end_outer_price    - @prev.end_inner_price
      next_.gain_loss_amount += next_.begin_inner_price - next_.begin_outer_price
      puts! next_, 'next_'
      puts! next_.gain_loss_amount, 'gain_loss_amount'
      @positions.push next_
    end
    @positions = @positions.reverse
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
    @strategies_list = Iro::Strategy.list(params[:long_or_short])
    @stocks_list    = Iro::Stock.list
  end

end
