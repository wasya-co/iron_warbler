
class Iro::PositionsController < Iro::ApplicationController
  before_action :set_lists

  def create
    @position = Iro::Position.new pos_params
    authorize! :create, @position

    @position.inner_strike = params[:inner][:strike]
    @position.outer_strike = params[:outer][:strike]

    o_attrs = {
      expires_on: @position.expires_on,
      put_call: @position.put_call, # I need this. _vp_ 2024-04-26
      stock_id: @position.stock_id,
    }
    @position.inner = Iro::Option.new params[:inner].permit!.merge( o_attrs )
    @position.inner.end_price = @position.inner.begin_price
    @position.inner.end_delta = @position.inner.begin_delta
    if [ Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD, Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD ].include?( @position.strategy.kind )
      @position.outer = Iro::Option.new params[:outer].permit!.merge( o_attrs )
      @position.outer.end_price = @position.outer.begin_price
      @position.outer.end_delta = @position.outer.begin_delta
    end

    if @position.save
      flash_notice @position
      redirect_to controller: :purses, action: :show, id: @position.purse_id.to_s
    else
      flash_alert @position
      redirect_to request.referrer # render action: :new
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

  def eval
    @position = Iro::Position.find params[:id]
    authorize! :edit, @position
    @position.calc_rollp

    if @position.rollp > 0.5
      @position.calc_nxt
    end

    flash[:notice] = 'Probably eval ed the position.'
    redirect_to request.referrer
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

    quotes_params = { contractType: @position.put_call, ticker: @stock.ticker, expirationDate: @prev.next_expires_on }
    # puts! quotes_params, 'quotes_params'
    @quotes = Tda::Option.get_quotes(quotes_params)

    self.send("_prepare_#{@position.strategy.kind}")
  end

  ## 2026-02-26 continue...
  ## short credit call spread
  ## covered call
  def prepare2
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position
    @position.update({
      status: Iro::Position::STATUS_PROPOSED,
    })
    if params[:prev_id]
      prev = Iro::Position.find params[:prev_id]
      prev.update({ autonxt_id: params[:id] })
      @position.reload
    else
      if @position.autoprev
        ;
      else
        throw 'I need prev_id'
      end
    end

    @query = case @position.strategy.kind
      when Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD
        Tda::Order.roll_short_credit_call_spread_q @position
      when Iro::Strategy::KIND_COVERED_CALL
        Tda::Order.roll_covered_call_q @position
      else
        throw 'pp0 - not implemented'
      end
  end

  ## 2026-02-26 continue...
  ## short credit call spread
  def prepare3
    @position = Iro::Position.find params[:id]
    authorize! :place_order, @position
    order_id = Tda::Order.place_order( Tda::Order.roll_short_credit_call_spread_q @position )

    flag = @position.update({
      schwab_order_id: order_id,
      status: Iro::Position::STATUS_PENDING,
    })

    flash_notice flag
    redirect_to controller: :purses, action: :show, template: :gameui, id: @position.purse_id
  end



  def _prepare_covered_call
    @positions = []
    (-@nn..@nn).each do |idx|
      inner_strike = @prev.inner.strike - idx*@stock.options_price_increment
      outer_strike = 0
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
          status:       Iro::Position::STATUS_PREPARE,
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
      end


      @quotes.map do |quote|
        if quote[:strikePrice] == next_.inner.strike
          price = ( quote[:bid] + quote[:ask] )/2
          next_.inner.begin_price = price
          next_.inner.end_price   = price
          next_.inner.begin_delta = quote[:delta]
          next_.inner.end_delta   = quote[:delta]
          next_.inner.save
        end
      end

      next_.next_gain_loss_amount  = next_.inner.begin_price - @prev.inner.end_price
      next_.save
      @positions.push next_
    end
    @positions = @positions.reverse
  end

  ## 2025-10-14 _TODO: move to a model?
  ## 2026-02-18 continue
  def _prepare_long_credit_put_spread
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
          status:       Iro::Position::STATUS_PREPARE,
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

      @quotes.map do |quote|
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

      next_.next_gain_loss_amount  = @prev.outer.end_price   - next_.outer.begin_price
      next_.next_gain_loss_amount += next_.inner.begin_price - @prev.inner.end_price
      next_.save
      @positions.push next_
    end
  end

  ## 2026-02-21 its not working
  ## 2026-02-26 I assume its working?
  def _prepare_short_credit_call_spread
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
          status:       Iro::Position::STATUS_PREPARE,
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

      @quotes.map do |quote|
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

      next_.next_gain_loss_amount  = @prev.outer.end_price   - next_.outer.begin_price
      next_.next_gain_loss_amount += next_.inner.begin_price - @prev.inner.end_price
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
      if pos.outer
        pos.outer.update params[:outer].permit!.merge( o_attrs )
      end

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
      :inner_strike,
      :long_or_short,
      :outer_strike,
      :purse_id, :put_call,
      :quantity,
      :status, :stock_id, :strategy_id,
    )
  end

  def set_lists
    super
    @purses_list     = Iro::Purse.list
    @strategies_list = Iro::Strategy.list(params[:long_or_short])
    @stocks_list     = Iro::Stock.list
  end

end
