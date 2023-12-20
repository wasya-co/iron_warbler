
class Iro::AlertsController < Iro::ApplicationController

  before_action :set_lists

  def create
    @alert = Iro::Alert.new(alert_params)
    if @alert.save
      redirect_to action: :index, notice: 'Alert was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @alert = Iro::Alert.find(params[:id])
    @alert.destroy
    redirect_to action: :index, notice: 'Alert was successfully destroyed.'
  end

  def index
    @alerts = Iro::Alert.all
  end

  def update
    @alert = Iro::Alert.find(params[:id])
    if @alert.update(alert_params)
      redirect_to action: :index, notice: 'Alert was successfully updated.'
    else
      render :edit
    end
  end

  ##
  ## private
  ##
  private

  def alert_params
    params.require(:alert).permit(:class_name, :kind, :symbol, :direction, :strike, :profile_id)
  end

  def set_lists
    # @profiles_list = Wco::Profile.list
    @stocks_list = [[nil,nil]] + Iro::Stock.active.map { |s| [ s.ticker, s.ticker ] }
  end


end

