

class Iro::PriceitemsController < Iro::ApplicationController

  def index
    authorize! :show, Iro::Priceitem
    @count = Iro::Priceitem.all.length
  end

end
