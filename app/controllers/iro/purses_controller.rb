
class Iro::PursesController < Iro::ApplicationController

  before_action :set_lists

  def create
    @purse = Iro::Purse.new params[:purse].permit!
    authorize! :create, @purse
    if @purse.save
      ;
    else
      flash_alert @purse
    end
    redirect_to action: :index
  end

  def destroy
    @purse = Iro::Purse.find(params[:id])
    authorize! :destroy, @purse
    @purse.destroy
    redirect_to action: :index, notice: 'Purse was successfully destroyed.'
  end

  def edit
    @purse = Iro::Purse.unscoped.find(params[:id]) rescue Iro::Purse.unscoped.find_by( slug: params[:id] )
    authorize! :edit, @purse
  end

  def index
    @purses = Iro::Purse.all.order_by( slug: :asc )
    authorize! :index, Iro::Purse
  end

  ## table or gameui
  def show
    @purse = Iro::Purse.unscoped.find(params[:id]) rescue Iro::Purse.unscoped.find_by( slug: params[:id] )
    authorize! :show, @purse
    @unit      = @purse.unit # 12  ## pixels per dollar
    @height    = @purse.height # 100  ## pixels
    @n_dollars = 30 ## * unit * 2 = length of the grid

    @positions = @purse.positions.where( :status.in => params[:vcfg][:statuses]
      ).includes( :strategy
      ).order_by( expires_on: :asc, ticker: :asc, long_or_short: :asc, inner_strike: :asc )

    calc_summary

    @page_title = @purse.to_s
    render params[:vcfg][:template]
  end

  def sync
    @purse = Iro::Purse.find(params[:id])
    authorize! :show, @purse

    @positions = @purse.positions.active
    expiration_dates = @positions.map { |p| p.expires_on.to_s }.sort
    quotes_h = Tda::Option.get_quotes_h({
      contractType: 'ALL',
      ticker:  @positions[0].ticker,
      fromDate: expiration_dates.first,
      toDate: expiration_dates.last,
    })
    # byebug

    count = 1
    @positions.each do |pos|
      pos.inner.end_price = quotes_h[pos.expires_on.to_s][pos.put_call][pos.inner.strike][:price]
      pos.inner.end_delta = quotes_h[pos.expires_on.to_s][pos.put_call][pos.inner.strike][:delta]
      pos.inner.save ? print("#{count}^") : print("#{count}X")
      if [ Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD, Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD ].include?( pos.strategy.kind )
        pos.outer.end_price = quotes_h[pos.expires_on.to_s][pos.put_call][pos.outer.strike][:price]
        pos.outer.end_delta = quotes_h[pos.expires_on.to_s][pos.put_call][pos.outer.strike][:delta]
        pos.outer.save ? print('^') : print('X')
      end
      count = count+1
    end

    flash[:notice] = 'Synced the purse.'
    redirect_to request.referrer
  end

  def update
    @purse = Iro::Purse.unscoped.find(params[:id]) rescue Iro::Purse.unscoped.find_by( slug: params[:id] )
    authorize! :update, @purse
    if @purse.update params[:purse].permit!
      flash[:notice] = 'ok'
      redirect_to request.referrer # purse_path(@purse)
    else
      flash_alert @purse
      render :edit
    end
  end

  ##
  ## private
  ##
  private

  ## for one stock only!
  def calc_summary
    @max_loss_long  = 0
    @max_loss_short = 0

    @max_gain_long  = 0
    @max_gain_short = 0

    @gain_long  = 0
    @gain_short = 0

    @delta_long_begin  = 0
    @delta_short_begin = 0
    @delta_long_end  = 0
    @delta_short_end = 0

    @positions.each do |pos|
      if Iro::Strategy::LONG == pos.strategy.long_or_short
        @max_loss_long += pos.max_loss * pos.q * 100
        @max_gain_long += pos.max_gain * pos.q * 100
        @gain_long     += pos.net_amount * pos.q * 100

        @delta_long_begin += pos.begin_delta * pos.q
        @delta_long_end   += pos.end_delta * pos.q
      end
      if Iro::Strategy::SHORT == pos.strategy.long_or_short
        @max_loss_short += pos.max_loss * pos.q * 100
        @max_gain_short += pos.max_gain * pos.q * 100
        @gain_short     += pos.net_amount * pos.q * 100

        @delta_short_begin += pos.begin_delta * pos.q
        @delta_short_end   += pos.end_delta * pos.q
      end
    end

    # @delta_long_begin *= -1
    # @delta_long_end *= -1

    ## 2026-05-07 being used.
    if @gain_long < 0
      @loss_long = @gain_long
      @gain_long = nil
    end
    if @gain_short < 0
      @loss_short = @gain_short
      @gain_short = nil
    end
  end

  def set_lists
    super
    # @tickers_list = [[nil,nil]] + Iro::Stock.active.map { |s| [ s.ticker, s.ticker ] }
    @stocks_list = Iro::Stock.list
  end


end






    ## lets only sync when I say.
    ## 2026-02-24
=begin
    expiration_dates = @positions.map { |p| p.expires_on.to_s }.sort
    quotes_h = Tda::Option.get_quotes_h({
      contractType: 'ALL',
      ticker:  @positions[0].ticker,
      fromDate: expiration_dates.first,
      toDate: expiration_dates.last,
    })
    count = 1
    @positions.each do |pos|
      pos.inner.end_price = quotes_h[pos.expires_on.to_s][pos.put_call][pos.inner.strike][:price]
      pos.inner.end_delta = quotes_h[pos.expires_on.to_s][pos.put_call][pos.inner.strike][:delta]
      pos.inner.save ? print("#{count}^") : print("#{count}X")
      if [ Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD, Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD ].include?( pos.strategy.kind )
        pos.outer.end_price = quotes_h[pos.expires_on.to_s][pos.put_call][pos.outer.strike][:price]
        pos.outer.end_delta = quotes_h[pos.expires_on.to_s][pos.put_call][pos.outer.strike][:delta]
        pos.outer.save ? print('^') : print('X')
      end
      count = count+1
    end
=end


