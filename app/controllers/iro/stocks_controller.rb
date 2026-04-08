
##
## https://www.macrotrends.net/stocks/charts/META/meta-platforms/stock-price-history
##
class Iro::StocksController < Iro::ApplicationController
  before_action :set_stock, only: [:destroy, :edit, :show, :update ]

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

  def destroy
    @stock.destroy
    redirect_to stocks_url, notice: 'Stock was successfully destroyed.'
  end

  def edit
    authorize! :edit, @stock
  end

  def index
    @all_stocks = Iro::Stock.all
    authorize! :index, Iro::Stock

    respond_to do |format|
      format.html
      format.json do
        render layout: false
      end
    end
  end

  def new
    @stock = Iro::Stock.new
    authorize! :new, @stock
  end

  def sync
    authorize! :refresh, Iro::Stock
    tickers = Iro::Stock.all.map { |s| s.ticker }.join(',')
    outs = Tda::Stock.get_quotes tickers
    puts! outs, 'got all tickers'

    outs.map do |out|
      puts! out, 'a ticker'

      Iro::Stock.where( ticker: out[:symbol] ).update_all( last: out[:last] )
    end
    flash_notice 'refreshed stocks'
    redirect_to request.referrer
  end

  def show
    authorize! :show, @stock

    @priceitems = ::Iro::Priceitem.where({
      ticker: @stock.ticker,
    })
    @datapoints = Iro::Datapoint.where({
      symbol: @stock.ticker,
    }).order_by({ date: :desc })
    if @datapoints.length == 0
      @stock.get_historic_data
      @datapoints = Iro::Datapoint.where({
        symbol: @stock.ticker,
      }).order_by({ date: :desc })
    end
    @datapoints_h = {}
    @datapoints.each do |dp|
      @datapoints_h[dp.date.to_s] = dp.value
    end

    respond_to do |format|
      format.html
      format.json do
        render layout: false
      end
    end
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


  ##
  ## private
  ##
  private

  def set_stock
    begin
      @stock = Iro::Stock.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound => e
      @stock = Iro::Stock.find_by ticker: params[:id]
    end
    @stocks_list = Iro::Stock.tickers_list
  end

  def stock_params
    params.require(:stock).permit!
  end

end

