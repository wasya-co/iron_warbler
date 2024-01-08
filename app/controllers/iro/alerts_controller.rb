
class Iro::AlertsController < Iro::ApplicationController

  before_action :set_lists

  def create
    @alert = Iro::Alert.new params[:alert].permit!
    authorize! :create, @alert
    if @alert.save
      redirect_to action: :index, notice: 'Alert was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @alert = Iro::Alert.find(params[:id])
    authorize! :destroy, @alert
    @alert.destroy
    redirect_to action: :index, notice: 'Alert was successfully destroyed.'
  end

  def index
    @alerts = Iro::Alert.all
    authorize! :index, Iro::Alert
  end

  def update
    @alert = Iro::Alert.find(params[:id])
    authorize! :update, @alert
    if @alert.update params[:alert].permit!
      redirect_to action: :index, notice: 'Alert was successfully updated.'
    else
      render :edit
    end
  end

  ##
  ## private
  ##
  private

  def set_lists
    # @profiles_list = Wco::Profile.list
    @stocks_list = [[nil,nil]] + Iro::Stock.active.map { |s| [ s.ticker, s.ticker ] }
  end


end

