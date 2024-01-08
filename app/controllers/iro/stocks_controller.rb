
class Iro::StocksController < Iro::ApplicationController
  before_action :set_stock, only: [:show, :edit, :update, :destroy]

  def index
    @stocks = Iro::Stock.all
    authorize! :index, Iro::Stock
  end

  def show
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
    @stock = Iro::Stock.find(params[:id])
  end

  def stock_params
    params.require(:stock).permit!
  end

end

