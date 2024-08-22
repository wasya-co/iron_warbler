
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
    @stocks = Iro::Stock.all
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
    outs.map do |out|
      Iro::Stock.where( ticker: out[:symbol] ).update( last: out[:last] )
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
    }).order_by({ date: :desc }).limit(100)

    ## @deprecated, use api/stocks_controller#max_pain
    hash = Tda::Option.get_chains({ ticker: @stock.ticker, force: false })
    @max_pain = Iro::Option.max_pain hash
    @max_pain_summary = {}
    @max_pain.each do |date, types|
      all = types['all']
      @max_pain_summary[date] = all.keys[0]
      all.each do |strike, amount|
        if amount < all[@max_pain_summary[date]]
          @max_pain_summary[date] = strike
        end
      end
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

