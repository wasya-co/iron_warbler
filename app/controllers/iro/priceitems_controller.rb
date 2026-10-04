

class Iro::PriceitemsController < Iro::ApplicationController

  def index
    authorize! :show, Iro::Priceitem
    @tickers = Iro::Stock.tickers_list
    scope = Iro::Priceitem.all
    scope = scope.where(ticker: params[:ticker]) if params[:ticker].present?
    @count = scope.count
  end

end
