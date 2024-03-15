
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
