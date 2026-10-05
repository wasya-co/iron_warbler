

class Iro::PriceitemsController < Iro::ApplicationController

  def index
    if !params[:ticker]
      params[:ticker] = 'META'
    end

    authorize! :show, Iro::Priceitem
    @tickers = Iro::Stock.tickers_list
    @stock = Iro::Stock.find_by ticker: params[:ticker]

    priceitems = Iro::Priceitem.all
    priceitems = priceitems.where(ticker: @stock.ticker)
    if params[:date].present?
      quote_at = Date.strptime(params[:date], '%Y-%m-%d')
      priceitems = priceitems.where(quote_at: quote_at)
    end

    @dates = Iro::Priceitem.collection.aggregate([
      { '$match' => priceitems.selector },
      { '$group' => {
        '_id' => { '$dateToString' => { 'format' => '%Y-%m-%d', 'date' => '$quote_at' } },
      } },
      { '$sort' => { '_id' => 1 } },
    ]).map { |r| Date.strptime(r['_id'], '%Y-%m-%d') }
    @count = priceitems.count
  end

  def on_date
    authorize! :show, Iro::Priceitem
    @stock = Iro::Stock.find_by ticker: params[:ticker]
    day_start = params[:date].to_date.in_time_zone('UTC').beginning_of_day
    @priceitems = Iro::Priceitem.where(
      ticker: @stock.ticker,
      :quote_at.gte => day_start,
      :quote_at.lt  => day_start + 1.day,
    )
  end

end
