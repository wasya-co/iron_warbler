
class Iro::PursesController < Iro::ApplicationController

  before_action :set_lists

  def create
    @purse = Iro::Purse.new params[:purse].permit!
    authorize! :create, @purse
    if @purse.save
      redirect_to action: :index, notice: 'Purse was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @purse = Iro::Purse.find(params[:id])
    authorize! :destroy, @purse
    @purse.destroy
    redirect_to action: :index, notice: 'Purse was successfully destroyed.'
  end

  def edit
    @purse = Iro::Purse.find(params[:id])
    authorize! :edit, @purse
  end

  def index
    @purses = Iro::Purse.all
    authorize! :index, Iro::Purse
  end

  def show
    @purse = Iro::Purse.find(params[:id])
    authorize! :show, @purse

    @positions = @purse.positions.includes( :strategy
      ).order({ expires_on: :desc })

    @unit      = @purse.unit # 12  ## pixels per dollar
    @height    = @purse.height # 100  ## pixels
    @n_dollars = 100 ## dollars to each side of origin

    render params[:template]
  end

  def update
    @purse = Iro::Purse.find(params[:id])
    authorize! :update, @purse
    if @purse.update params[:purse].permit!
      flash[:notice] = 'ok'
      redirect_to purse_path(@purse)
    else
      flash_alert @purse
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

