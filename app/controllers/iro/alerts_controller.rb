
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
      flash_notice 'ok'
    else
      flash_alert @alert
    end
    redirect_to action: :index, notice: 'Alert was successfully updated.'
  end

  ##
  ## private
  ##
  private

  def set_lists
    super

    # @profiles_list = Wco::Profile.list
    @stocks_list = Iro::Stock.list
    puts! @stocks_list, '@stocks_list'
  end


end

