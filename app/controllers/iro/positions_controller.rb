
class Iro::PositionsController < Iro::ApplicationController

  def check
    @position = Iro::Position.find params[:id]
    authorize! :check, @position
    outs = Tda::Order.check_status @position.schwab_order_id
    puts! outs, 'outs'

    if outs[:errors]
      flash[:alert] = 'need to sync?!'
      redirect_to request.referrer
      return
    end

    attrs = { schwab_status: outs[:status] }
    if 'FILLED' == outs[:status]
      attrs[:status] = Iro::Position::STATUS_CLOSED
      outs[:orderLegCollection].each do |leg|
        hash = Iro::Option.symbol_to_h leg[:instrument][:symbol]
        price = outs[:orderActivityCollection][0][:executionLegs].select do |exec_leg|
          exec_leg[:instrumentId] == leg[:instrument][:instrumentId]
        end[0][:price]
        if @position.inner.matches_h( hash )
          attrs[:inner_attributes] = { end_price: price }
        end
        if @position.outer.matches_h( hash )
          attrs[:outer_attributes] = { end_price: price }
        end
      end
    end
    puts! attrs,' attrs'
    @position.update(attrs)

    redirect_to request.referrer
  end

  def close_prep2
    @position = Iro::Position.find params[:id]
    authorize! :close, @position
    @position.inner.sync
    # @position.inner.update({ begin_price: @position.inner.end_price })
    @position.outer.sync
    # @position.outer.update({ begin_price: @position.outer.end_price })
    @position.update({ pending_price: @position.close_price, intent: Iro::Position::INTENT_CLOSE })
    @query = Tda::Order.close_credit_spread_q @position
    @page_title = "Closing #{@position} ..."
  end

  def create
    @position = Iro::Position.new pos_params
    authorize! :create, @position

    # @position.inner_strike = params[:inner][:strike]
    # @position.outer_strike = params[:outer][:strike]

    o_attrs = {
      expires_on: @position.expires_on,
      put_call:   @position.put_call, # I need this. _vp_ 2024-04-26
      stock_id:   @position.stock_id,
    }
    @position.inner = Iro::Option.create!({ strike: params[:position][:inner_strike] }.merge( o_attrs ))
    @position.inner.sync
    @position.inner.begin_price = @position.inner.end_price
    @position.inner.begin_delta = @position.inner.end_delta

    case @position.strategy.kind
    when Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD,
         Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD
      @position.outer = Iro::Option.create!({ strike: params[:position][:outer_strike] }.merge( o_attrs ))
      @position.outer.sync
      @position.outer.begin_price = @position.outer.end_price
      @position.outer.begin_delta = @position.outer.end_delta
    when Iro::Strategy::KIND_DIAG_LONG_CALL_SPREAD,
         Iro::Strategy::KIND_DIAG_SHORT_PUT_SPREAD
      @position.outer = Iro::Option.create!({ strike: params[:position][:outer_strike] }.merge( o_attrs ))
      @position.outer.sync
      @position.outer.begin_price = @position.outer.end_price
      @position.outer.begin_delta = @position.outer.end_delta
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
    set_position_lists
  end

  def eval
    @position = Iro::Position.find params[:id]
    authorize! :edit, @position
    @position.calc_rollp

    if @position.rollp > 0.5
      @position.calc_nxt
    end

    flash[:notice] = 'called position.calc_rollp , maybe position.calc_nxt .'
    redirect_to request.referrer
  end

  def index
    authorize! :index, Iro::Position
    params[:vcfg] ||= {} # "view config"
    template = params[:vcfg][:template] || Iro::Purse::TEMPLATE_TABLE

    @purse = Iro::Purse.find_by( slug: 'all' )
    @positions = Iro::Position.all().includes( :strategy, :inner, :outer, :stock, :purse
      ).order_by( expires_on: :asc, ticker: :asc, long_or_short: :asc, inner_strike: :asc )

    if params[:vcfg][:statuses]
      @positions = @positions.where( :status.in => params[:vcfg][:statuses] )
    end

    puts! @positions

    @page_title = 'All Positions'
  end

  ## only callable from _new.haml, with position partially pre-filled
  def new
    authorize! :new, Iro::Position
    strategy    = Iro::Strategy.find params[:position][:strategy_id]

    @position   = strategy.next_position
    @position ||= Iro::Position.new( params[:position].permit!.merge({
      put_call: strategy.put_call,
      status:   Iro::Position::STATUS_PROPOSED,
      # inner:    Iro::Option.new,
      # outer:    Iro::Option.new,
      stock_id: strategy.stock_id,
    }) )

    set_position_lists
  end


  ## credit-spread
  def open
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position
    @position.inner.sync
    @position.inner.update({ begin_price: @position.inner.end_price })
    @position.outer.sync
    @position.outer.update({ begin_price: @position.outer.end_price })
    @position.update({ pending_price: @position.open_price })
    @query = @position.schwab_query # Tda::Order.credit_spread_q @position
  end

  def place_order
    @position = Iro::Position.find params[:id]
    authorize! :place_order, @position

    query = case @position.intent
    when Iro::Position::INTENT_CLOSE
      Tda::Order.close_credit_spread_q @position
    else
      throw '_TODO: hls - placing order, not implemented'
    end
    outs = Tda::Order.place_order!( query )

    flag = @position.update({
      schwab_order_id: outs[:schwab_order_id],
      schwab_status: outs[:schwab_status],
      status: Iro::Position::STATUS_PENDING,
    })

    flash_notice flag
    redirect_to controller: :purses, action: :show, template: 'show', view_status: 'pending', id: @position.purse_id
  end

    ## only open   credit-spread,
  ##      roll a credit-spread
  def reprice
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position
    flash_notice @position.update({ pending_price: params[:pending_price] })

    if @position.schwab_order_id
      Tda::Order.cancel_order!( @position.schwab_order_id )
      outs = Tda::Order.place_order!( @position.schwab_query )
      flag = @position.update({
        schwab_order_id: outs[:schwab_order_id],
        schwab_status:   outs[:schwab_status],
        status:          Iro::Position::STATUS_PENDING,
      })
      flash_notice "Updated schwab order!"
    end

    redirect_to request.referrer
  end

  def roll_inner
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position
  end


  def show
    @position = Iro::Position.find params[:id]
    authorize! :show, @position
  end

  ## 2025-10-14 long_credit_put_spread
  ## 2026-02-21 short_credit_call_spread
  ## That's for looking at the ui, with buttons 'select'
  def prepare
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position

    @prev      = @position
    @purse     = @position.purse
    @stock     = @position.stock
    @nn        = @position.purse.n_next_positions
    @n_dollars = 50 ## * unit * 2 = length of the grid

    quotes_params = { contractType: @position.put_call, ticker: @stock.ticker, expirationDate: @prev.next_expires_on }
    # puts! quotes_params, 'quotes_params'
    @quotes = Tda::Option.get_quotes(quotes_params)

    @page_title = "Prepare #{@position}"
    self.send("_prepare_#{@position.strategy.kind}")
  end

  ## Manually selected one, I suppose
  ## _TODO: pos is autonext position, but should be this position?
  ## rename to: def select ?
  def prepare2
    if params[:prev_id]
      prev = Iro::Position.find params[:prev_id]
      prev.update({ autonxt_id: params[:id] })
      Iro::Position.where( prev_id: params[:prev_id], status: 'proposed' ).update_all( status: 'prepare' )
    end

    @position = Iro::Position.find params[:id]
    authorize! :roll, @position
    @position.update({
      status: Iro::Position::STATUS_PROPOSED,
      intent: @position.strategy.intent,
      pending_price: @position.roll_price,
    })

    @query = case @position.strategy.kind
    when Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD,
          Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD
      Tda::Order.roll_credit_call_spread_q @position
    when Iro::Strategy::KIND_COVERED_CALL
      Tda::Order.roll_covered_call_q @position
    else
      throw 'pp0 - not implemented'
    end

    @page_title = "Prepare #{@position.stock.ticker} - #{@position}"
  end

  ## 2026-04-08 try-close only so far.
  ## pos is this position, not autonext.
  def prepare2_intent
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position
    case @position.strategy.intent
    when Iro::Strategy::INTENT_CLOSE

      @position.inner.sync
      @position.inner.update({ begin_price: @position.inner.end_price })
      @position.outer.sync
      @position.outer.update({ begin_price: @position.outer.end_price })
      @position.update({ pending_price: @position.close_price, intent: Iro::Position::INTENT_CLOSE })
      # @query = Tda::Order.close_credit_spread_q @position

    else
      throw 'unknown intent - trt'
    end

  end


  ## credit-spread
  def place3
    @position = Iro::Position.find params[:id]
    @position.update({ pending_price: params[:pending_price] })
    authorize! :place_order, @position
    outs = Tda::Order.place_order!( Tda::Order.credit_spread_q @position )

    flag = @position.update({
      schwab_order_id: outs[:schwab_order_id],
      schwab_status: outs[:schwab_status],
      status: Iro::Position::STATUS_PENDING,
    })

    flash_notice flag
    redirect_to controller: :purses, action: :show, template: 'show', view_status: 'pending', id: @position.purse_id
  end

  ## 2026-02-26 continue...
  ## short credit call spread
  def prepare3
    @position = Iro::Position.find params[:id]
    authorize! :place_order, @position
    outs = Tda::Order.place_order!( Tda::Order.roll_credit_call_spread_q @position )

    flag = @position.update({
      schwab_order_id: outs[:schwab_order_id],
      schwab_status: outs[:schwab_status],
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


  def update
    pos = @position = Iro::Position.find params[:id]
    authorize! :update, @position

    if @position.update pos_params

      pos.inner.update params[:inner].permit!
      if pos.outer
        pos.outer.update params[:outer].permit!
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
      :realized_gain_loss_amount,
      :status, :stock_id, :strategy_id,
    )
  end

  def set_position_lists
    @stocks_list     = Iro::Stock.list
    @strategies_list = ( @position.purse.strategies.list + [[ @position.strategy.to_s, @position.strategy.id.to_s ]] ).uniq
  end

end






  ##
  ## only updates some attributes
  ## 2026-04-29 :: not sure what it was about - but outer cannot inherit positions's expires_on, if I'm in a diagonal spread
  ##
  # def update
  #   pos = @position = Iro::Position.find params[:id]
  #   authorize! :update, @position
  #   if @position.update pos_params
  #     o_attrs = {
  #       expires_on: pos.expires_on,
  #     }
  #     pos.inner.update params[:inner].permit!.merge( o_attrs )
  #     if pos.outer
  #       pos.outer.update params[:outer].permit!.merge( o_attrs )
  #     end
  #     flash_notice @position
  #     redirect_to controller: :purses, action: :show, id: @position.purse_id.to_s
  #   else
  #     flash_alert @position
  #     redirect_to request.referrer
  #   end
  # end

