require_dependency "iro/application_controller"


class Iro::AlertsController < ApplicationController
  before_action :set_alert, only: [:show, :edit, :update, :destroy]

  def index
    @alerts = Iro::Alert.all
  end

  def show
  end

  def new
    @alert = Iro::Alert.new
  end

  def edit
  end

  def create
    @alert = Iro::Alert.new(alert_params)

    if @alert.save
      redirect_to @alert, notice: 'Alert was successfully created.'
    else
      render :new
    end
  end

  def update
    if @alert.update(alert_params)
      redirect_to @alert, notice: 'Alert was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @alert.destroy
    redirect_to alerts_url, notice: 'Alert was successfully destroyed.'
  end

  ##
  ## private
  ##
  private

  def set_alert
    @alert = Iro::Alert.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:class_name, :kind, :symbol, :direction, :strike, :profile_id)
  end

end

