
class Iro::PositionsController < Iro::ApplicationController
  before_action :set_lists

  def new
    @position = Iro::Position.new purse_id: params[:purse_id]
    authorize! :new, @posision
  end

  def create
    @position = Iro::Position.new params[:position].permit!
    authorize! :create, @position

    if @position.save
      flash_notice @position
      redirect_to controller: :purses, action: :show, id: @position.purse_id.to_s
    else
      flash_alert @position
      redirect_to request.referrer
    end
  end

  def destroy
    @position = Iro::Position.find params[:id]
    authorize! :destroy, @position
    @position.delete
    flash_notice "Probably ok"
    redirect_to request.referrer
  end

  def edit
    @position = Iro::Position.find params[:id]
    authorize! :edit, @position
  end

  def roll
    @position = Iro::Position.find params[:id]
    authorize! :roll, @position

    stock = @position.stock

    @positions = [
      Iro::Position.new({ stock: stock, begin_inner_price: 5.21, inner_strike: 91, expires_on: '2024-04-05', gain_loss_amount: -1.25 }),
      Iro::Position.new({ stock: stock, begin_inner_price: 5.77, inner_strike: 90, expires_on: '2024-04-05', gain_loss_amount: -0.7 }),
      Iro::Position.new({ stock: stock, begin_inner_price: 6.4, inner_strike: 89, expires_on: '2024-04-05', gain_loss_amount: -0.03 }),
      Iro::Position.new({ stock: stock, begin_inner_price: 6.85, inner_strike: 88, expires_on: '2024-04-05', gain_loss_amount: 0.6 }),
      Iro::Position.new({ stock: stock, begin_inner_price: 7.07, inner_strike: 87, expires_on: '2024-04-05', gain_loss_amount: 1.22 }),
    ]
  end

  def update
    @position = Iro::Position.find params[:id]
    authorize! :update, @position

    if @position.update params[:position].permit!
      flash_notice @position
      redirect_to controller: :purses, action: :show, id: @position.purse_id.to_s
    else
      flash_alert @position
      redirect_to request.referrer
    end
  end

  ##
  ## private
  ##
  private

  def set_lists
    @strategies_list = Iro::Strategy.list(params[:long_or_short])
    @stocks_list    = Iro::Stock.list
  end

end
