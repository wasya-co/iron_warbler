
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
    pos.outer = Iro::Option.new params[:outer].permit!.merge( o_attrs )

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

    @position.calc_nxt

    # if params[:id]
    #   old = Iro::Position.find params[:id]
    #   old = old.attributes
    #   old.delete :_id
    #   puts! old, 'old'
    #   @position = Iro::Position.new old
    # end
  end

  ## 2025-10-14
  ## long_credit_put_spread
  def prepare
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position
    @n_dollars = 100 ## used in the view, but the name is unclear

    @prev  = @position
    @purse = @position.purse
    @stock = @position.stock

    @nn = ( @position.purse.n_next_positions/2 ).ceil ## @nn == @n_next_positions

    ## dealing with too many strikes in the chain
    while true
      upper = Tda::Option.get_quote({
        contractType:   @position.inner.put_call,
        strike:         @prev.inner.strike + @nn*@stock.options_price_increment, ## _TODO 2026-02-16: no more options_price_increment, just get strickes "around" current.
        expirationDate: @prev.next_expires_on,
        ticker:         @stock.ticker,
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
        contractType: @position.inner.put_call,
        strike: @prev.inner.strike - @nn*@stock.options_price_increment,
        expirationDate: @prev.next_expires_on,
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
      next_.sync
      next_.begin_inner_price = next_.end_inner_price
      next_.begin_inner_delta = next_.end_inner_delta
      next_.next_gain_loss_amount  = next_.begin_inner_price  - @prev.end_inner_price
      @positions.push next_
    end
  end

  ## 2025-10-14 _TODO: move to a model?
  ##            _TODO: what does this do, exactly?
  def _prepare_long_credit_put_spread
    ## get quotes for next expires_at
    # quotes = Tda::Option.get_quotes({ contractType: @position.put_call
    @positions = []
    (-@nn..@nn).each do |idx|
      next_ = Iro::Position.find_or_create_by({
        expires_on:   @prev.next_expires_on,
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
      @positions.push next_
    end
  end

  def _prepare_long_debit_call_spread
    @positions = []
    (-@nn..@nn).each do |idx|
      next_ = Iro::Position.find_or_create_by({
        expires_on:   @prev.next_expires_on,
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
      @positions.push next_
    end
    @positions = @positions.reverse
  end
  alias_method :_prepare_short_debit_put_spread, :_prepare_long_debit_call_spread
  alias_method :_prepare_short_credit_call_spread, :_prepare_long_debit_call_spread


  def sync
    @position = pos = Iro::Position.find params[:id]
    authorize! :refresh, @position

    @position.sync
    @position.calc_rollp
    if true # @position.rollp > 0.5
      @position.calc_nxt
    end

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
