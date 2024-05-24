
class Iro::Api::StocksController < Iro::ApiController
  before_action :set_stock, only: [:show, :edit, :update, :destroy]

  def index
    @stocks = Iro::Stock.active
    authorize! :index, Iro::Stock

    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    authorize! :show, @stock
    end_on = Time.now.to_date.in_time_zone('UTC')

    begin_on = ( Time.now - 1.year ).to_date.in_time_zone('UTC')
    begin_on = params[:begin_on].to_date.in_time_zone('UTC') if params[:begin_on]
    end_on   = params[:end_on].to_date.in_time_zone('UTC')   if params[:end_on]

    case params[:period]
    when '1-mo'
      begin_on = ( Time.now - 30.days ).to_date.in_time_zone('UTC')
      # end_on   = Time.now.to_date.in_time_zone('UTC')
    when '3-mo'
      begin_on = ( Time.now - 90.days ).to_date.in_time_zone('UTC')
      # end_on   = Time.now.to_date.in_time_zone('UTC')
    when '1-yr'
      begin_on = ( Time.now - 1.year ).to_date.in_time_zone('UTC')
      # end_on   = Time.now.to_date.in_time_zone('UTC')
    when '5-yr'
      begin_on = ( Time.now - 5.years ).to_date.in_time_zone('UTC')
    end

    @datapoints = Iro::Datapoint.where({
      :quote_at.gte => begin_on,
      :quote_at.lte => end_on,
      symbol:          params[:ticker],
    }).order_by({ quote_at: :asc })
  end

  def new
    @stock = Iro::Stock.new
    authorize! :new, @stock
  end

  def edit
  end

  def create
    @stock = Iro::Stock.new(stock_params)
    authorize! :create, @stock

    if @stock.save
      flash_notice @stock
    else
      flash_alert @stock
    end
    redirect_to action: :index
  end

  def update
    @stock = Iro::Stock.find params[:id]
    authorize! :update, @stock
    if @stock.update(stock_params)
      flash_notice @stock
    else
      flash_alert @stock
    end
    redirect_to request.referrer
  end

  def destroy
    @stock.destroy
    redirect_to stocks_url, notice: 'Stock was successfully destroyed.'
  end

  ##
  ## private
  ##
  private

  def set_stock
    @stock = Iro::Stock.find_by({ ticker: params[:ticker] })
  end

end

