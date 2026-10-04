

class Iro::PriceitemsController < Iro::ApplicationController

  def index
    authorize! :show, Iro::Priceitem
    @tickers = Iro::Stock.tickers_list
    scope = Iro::Priceitem.all
    scope = scope.where(ticker: params[:ticker]) if params[:ticker].present?
    if params[:date].present?
      quote_at = Date.strptime(params[:date], '%Y-%m-%d')
      scope = scope.where(quote_at: quote_at)
    end

    @dates = Iro::Priceitem.collection.aggregate([
      { '$match' => scope.selector },
      { '$group' => {
        '_id' => { '$dateToString' => { 'format' => '%Y-%m-%d', 'date' => '$quote_at' } },
      } },
      { '$sort' => { '_id' => 1 } },
    ]).map { |r| Date.strptime(r['_id'], '%Y-%m-%d') }
    @count = scope.count
  end

end
