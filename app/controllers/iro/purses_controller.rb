
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
    @purse = Iro::Purse.find(params[:id])
    authorize! :edit, @purse
  end

  def index
    @purses = Iro::Purse.all
    authorize! :index, Iro::Purse
  end

  ## table or gameui
  def show
    @purse = Iro::Purse.find(params[:id])
    params[:template] = params[:template].presence || 'show'
    authorize! :show, @purse

    @positions = @purse.positions
    if params[:view_status] && 'all' != params[:view_status]
      @positions = @positions.where( status: params[:view_status] )
    end
    @positions = @positions.includes( :strategy
      ).order( expires_on: :asc, ticker: :desc, long_or_short: :asc, inner_strike: :asc )

    ## this used to update inner, outer price, delta of each position:
    # @positions.each { |p| p.sync }
    ## but now I bundle it all together:
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
      pos.outer.end_price = quotes_h[pos.expires_on.to_s][pos.put_call][pos.outer.strike][:price]
      pos.outer.end_delta = quotes_h[pos.expires_on.to_s][pos.put_call][pos.outer.strike][:delta]
      pos.outer.save ? print('^') : print('X')
      count = count+1
    end

    @unit      = @purse.unit # 12  ## pixels per dollar
    @height    = @purse.height # 100  ## pixels
    @n_dollars = 100 ## dollars to each side of origin

    calc_summary

    render params[:template]
  end

  def update
    @purse = Iro::Purse.find(params[:id])
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

    @begin_delta_long  = 0
    @begin_delta_short = 0
    @end_delta_long  = 0
    @end_delta_short = 0

    @positions.each do |pos|
      if Iro::Strategy::LONG == pos.strategy.long_or_short
        @max_loss_long += pos.max_loss * pos.q * 100
        @max_gain_long += pos.max_gain * pos.q * 100
        @gain_long     += pos.net_amount * pos.q * 100

        @begin_delta_long += pos.begin_delta * pos.q
        @end_delta_long   += pos.end_delta * pos.q
      end
      if Iro::Strategy::SHORT == pos.strategy.long_or_short
        @max_loss_short += pos.max_loss * pos.q * 100
        @max_gain_short += pos.max_gain * pos.q * 100
        @gain_short     += pos.net_amount * pos.q * 100

        @begin_delta_short += pos.begin_delta * pos.q
        @end_delta_short   += pos.end_delta * pos.q
      end
    end
    # @max_loss_long *= -1
    # @max_loss_short *= -1
    @begin_delta_short *= -1
    @end_delta_short *= -1
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

    # @profiles_list = Wco::Profile.list
    # @tickers_list = [[nil,nil]] + Iro::Stock.active.map { |s| [ s.ticker, s.ticker ] }
    @stocks_list = Iro::Stock.list

  end


end

