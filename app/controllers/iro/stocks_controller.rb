
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
      @stock = Iro::Stock.unscoped.find_by ticker: stock_params[:ticker]
      flag = @stock.update( deleted_at: nil, options_price_increment: stock_params[:options_price_increment] )
      flash_alert @stock
    end
    redirect_to action: :index
  end

  def destroy
    authorize! :destroy, @stock
    @stock.destroy
    redirect_to stocks_url, notice: 'Stock was destroyed.'
  end

  def edit
    authorize! :edit, @stock
  end

  def get_historic_data
    authorize! :show, Iro::Stock
    @stock = Iro::Stock.find params[:id]
    @stock.get_historic_data( params[:date_from].to_date )
    redirect_to action: :show, id: params[:id]
  end

  def recompute_volatility
    authorize! :show, Iro::Stock
    @stock = Iro::Stock.find params[:id]
    @stock.volatility( recompute: true )
    redirect_to action: :show, id: params[:id]
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

    outs.map do |out|
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
    @datapoints_arr = @datapoints.map { |dp| { date: dp.date, value: dp.value } }

    min = (@stock.min / @stock.step) * @stock.step
    max = @stock.max


    @datapoints_1mo = {
      items: Iro::Datapoint.where({
        symbol: @stock.ticker,
        :date.gte => Time.now - 1.month,
      }).order_by({ date: :asc }),
      min: @stock.min,
      max: @stock.max,
    };
    pipeline = [
      { "$match" => { symbol: @stock.ticker,
                      date: { "$gte" => Time.now - 1.month } } },
      {
        "$project" => {
          bucket: {
            "$let" => {
              vars: {
                b: { "$multiply" => [
                  { "$floor" => { "$divide" => ["$value", @stock.step] } },
                  @stock.step
                ] }
              },
              in: {
                "$cond" => [
                  { "$lt" => ["$$b", @stock.min] },
                  @stock.min,
                  {
                    "$cond" => [
                      { "$gt" => ["$$b", @stock.max] },
                      @stock.max,
                      "$$b"
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      { "$group" => { _id: "$bucket",
                      count: { "$sum" => 1 } } },
      { "$sort" => { "_id" => 1 } },
    ]
    result = Iro::Datapoint.collection.aggregate(pipeline).to_a
    map = result.to_h { |r| [r["_id"].to_i, r["count"]] }
    puts! map, '1mo map'
    filled = (@stock.min..@stock.max).step(@stock.step).map do |bucket|
      {
        bucket: bucket,
        count: map[bucket] || 0,
      }
    end
    @histogram_1mo = {
      items: filled,
      label: '1mo',
      min: 0,
      max: 10,
    };
    # puts! @histogram_1mo, '@histogram_1mo'



    @datapoints_3mo = {
      items: Iro::Datapoint.where({
        symbol: @stock.ticker,
        :date.gte => Time.now - 3.months,
      }).order_by({ date: :asc }),
      min: @stock.min,
      max: @stock.max,
    };
    pipeline = [
      { "$match" => { symbol: @stock.ticker,
                      date: { "$gte" => Time.now - 3.months } } },
      {
        "$project" => {
          bucket: {
            "$let" => {
              vars: {
                b: { "$multiply" => [
                  { "$floor" => { "$divide" => ["$value", @stock.step] } },
                  @stock.step
                ] }
              },
              in: {
                "$cond" => [
                  { "$lt" => ["$$b", @stock.min] },
                  @stock.min,
                  {
                    "$cond" => [
                      { "$gt" => ["$$b", @stock.max] },
                      @stock.max,
                      "$$b"
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      { "$group" => { _id: "$bucket",
                      count: { "$sum" => 1 } } },
      { "$sort" => { "_id" => 1 } },
    ]
    result = Iro::Datapoint.collection.aggregate(pipeline).to_a
    puts! result, '3mo result'
    map = result.to_h { |r| [r["_id"].to_i, r["count"]] }
    puts! map, '3mo map'
    filled = (@stock.min..@stock.max).step(@stock.step).map do |bucket|
      puts! bucket, 'a 3mo bucket'
      {
        bucket: bucket,
        count: map[bucket] || 0,
      }
    end
    puts! filled, '3mo filled'
    @histogram_3mo = {
      items: filled,
      label: '3mo',
      min: 0,
      max: 10,
    };
    # puts! @histogram_3mo, '@histogram_3mo'



    @datapoints_6mo = {
      items: Iro::Datapoint.where({
        symbol: @stock.ticker,
        :date.gte => Time.now - 6.months,
      }).order_by({ date: :asc }),
      min: @stock.min,
      max: @stock.max,
    };
    pipeline = [
      { "$match" => { symbol: @stock.ticker,
                      date: { "$gte" => Time.now - 6.months } } },
      {
        "$project" => {
          bucket: {
            "$let" => {
              vars: {
                b: { "$multiply" => [
                  { "$floor" => { "$divide" => ["$value", @stock.step] } },
                  @stock.step
                ] }
              },
              in: {
                "$cond" => [
                  { "$lt" => ["$$b", @stock.min] },
                  @stock.min,
                  {
                    "$cond" => [
                      { "$gt" => ["$$b", @stock.max] },
                      @stock.max,
                      "$$b"
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      { "$group" => { _id: "$bucket",
                      count: { "$sum" => 1 } } },
      { "$sort" => { "_id" => 1 } },
    ]
    result = Iro::Datapoint.collection.aggregate(pipeline).to_a
    map = result.to_h { |r| [r["_id"].to_i, r["count"]] }
    filled = (@stock.min..@stock.max).step(@stock.step).map do |bucket|
      {
        bucket: bucket,
        count: map[bucket] || 0,
      }
    end
    @histogram_6mo = {
      items: filled,
      label: '6mo',
      min: 0,
      max: 10,
    };


    @datapoints_1yr = {
      items: Iro::Datapoint.where({
        symbol: @stock.ticker,
        :date.gte => Time.now - 1.year,
      }).order_by({ date: :asc }),
      min: min,
      max: max,
    };
    pipeline = [
      { "$match" => { symbol: @stock.ticker,
                      date: { "$gte" => Time.now - 1.year } } },
      {
        "$project" => {
          bucket: {
            "$let" => {
              vars: {
                b: { "$multiply" => [
                  { "$floor" => { "$divide" => ["$value", @stock.step] } },
                  @stock.step
                ] }
              },
              in: {
                "$cond" => [
                  { "$lt" => ["$$b", @stock.min] },
                  @stock.min,
                  {
                    "$cond" => [
                      { "$gt" => ["$$b", @stock.max] },
                      @stock.max,
                      "$$b"
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      { "$group" => { _id: "$bucket",
                      count: { "$sum" => 1 } } },
      { "$sort" => { "_id" => 1 } },
    ]
    result = Iro::Datapoint.collection.aggregate(pipeline).to_a
    map = result.to_h { |r| [r["_id"].to_i, r["count"]] }
    filled = (@stock.min..@stock.max).step(@stock.step).map do |bucket|
      {
        bucket: bucket,
        count: map[bucket] || 0,
      }
    end
    @histogram_1yr = {
      items: filled,
      label: '1yr',
      min: 0,
      max: 10,
    };


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

  def viz_1
    @stock = Iro::Stock.find params[:id]
    authorize! :show, @stock

    @chart_data = {
      calls: [],
      calls_1: [],

      min:  @stock.min,
      max:  @stock.max,

      last: [{ strike: @stock.last, implied: @stock.last }],

      puts: [],
      puts_1: [],
    };

    @quotes = Tda::Option.get_quotes({ contractType: 'CALL', ticker: @stock.ticker, expirationDate: params[:expires_on] })
    # @quotes = @quotes.reverse
    # puts! @quotes, '@quotes'
    @quotes.each do |q|
      implied = q[:strikePrice] + ( q[:bid] + q[:ask] )/2
      obj = {
        strike: q[:strikePrice],
        implied: implied,
        price: ( q[:bid] + q[:ask] )/2,
        put_call: q[:putCall],
      }
      # puts! obj, 'obj'
      @chart_data[:calls].push(obj)
    end

    exp_1 = (params[:expires_on].to_date+21.days).to_date
    puts! exp_1, 'exp_1'

    @quotes = Tda::Option.get_quotes({ contractType: 'CALL', ticker: @stock.ticker, expirationDate: exp_1 })
    # @quotes = @quotes.reverse
    # puts! @quotes, '@quotes'
    @quotes.each do |q|
      implied = q[:strikePrice] + ( q[:bid] + q[:ask] )/2
      obj = {
        strike: q[:strikePrice],
        implied: implied,
        price: ( q[:bid] + q[:ask] )/2,
        put_call: "#{q[:putCall]}-1",
      }
      # puts! obj, 'obj'
      @chart_data[:calls_1].push(obj)
    end


    @quotes = Tda::Option.get_quotes({ contractType: 'PUT', ticker: @stock.ticker, expirationDate: params[:expires_on] })
    # puts! @quotes, '@quotes'
    @quotes.each do |q|
      implied = q[:strikePrice] - ( q[:bid] + q[:ask] )/2
      obj = {
        strike: q[:strikePrice],
        implied: implied,
        price: ( q[:bid] + q[:ask] )/2,
        put_call: q[:putCall],
      }
      # puts! obj, 'obj'
      @chart_data[:puts].push(obj)
    end
    @quotes = Tda::Option.get_quotes({ contractType: 'PUT', ticker: @stock.ticker, expirationDate: exp_1 })
    # puts! @quotes, '@quotes'
    @quotes.each do |q|
      implied = q[:strikePrice] - ( q[:bid] + q[:ask] )/2
      obj = {
        strike: q[:strikePrice],
        implied: implied,
        price: ( q[:bid] + q[:ask] )/2,
        put_call: q[:putCall],
      }
      # puts! obj, 'obj'
      @chart_data[:puts_1].push(obj)
    end


    # puts! @chart_data, '@chart_data'

    # get all options at this expiration. call only.
    # plot price + premium.
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

