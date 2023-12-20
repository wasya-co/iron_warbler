
class Iro::StocksController < Iro::ApplicationController
  before_action :set_stock, only: [:show, :edit, :update, :destroy]

  def index
    @stocks = Iro::Stock.all
  end

  def show
  end

  def new
    @stock = Iro::Stock.new
  end

  def edit
  end

  def create
    @stock = Iro::Stock.new(stock_params)

    if @stock.save
      redirect_to action: :index, notice: 'Stock was successfully created.'
    else
      render :new
    end
  end

  def update
    if @stock.update(stock_params)
      redirect_to @stock, notice: 'Stock was successfully updated.'
    else
      render :edit
    end
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

