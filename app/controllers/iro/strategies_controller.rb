
class Iro::StrategiesController < Iro::ApplicationController

  before_action :set_lists

  def create
    @strategy = Iro::Strategy.new params[:strategy].permit!
    authorize! :create, @strategy

    if @strategy.save
      flash_notice @strategy
    else
      flash_alert @strategy
    end

    redirect_to action: :index
  end

  def destroy
    @strategy = Iro::Strategy.find params[:id]
    authorize! :destroy, @strategy
    @strategy.delete
    flash_notice "Probably ok"
    redirect_to request.referrer
  end

  def edit
    @strategy = Iro::Strategy.find params[:id]
    authorize! :edit, @strategy
  end

  def index
    authorize! :index, Iro::Strategy
    @strategies = Iro::Strategy.all

    # render '_table'
  end

  def new
    @strategy = Iro::Strategy.new
    authorize! :new, @posision
  end

  def show
    @strategy = Iro::Strategy.find params[:id]
    authorize! :show, @strategy
  end



  def update
    @strategy = Iro::Strategy.find params[:id]
    authorize! :update, @strategy

    if @strategy.update params[:strategy].permit!
      flash_notice @strategy
    else
      flash_alert @strategy
    end

    redirect_to action: :index
  end

  ##
  ## private
  ##
  private

  def set_lists
    super

    @purses_list     = Iro::Purse.list
    @strategies_list = Iro::Strategy.list
    @stocks_list     = Iro::Stock.list
  end

end
