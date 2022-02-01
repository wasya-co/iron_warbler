
class IshManager::StockWatchesController < IshManager::ApplicationController

  layout 'ish_manager/application2'

  ## alphabetized : )

  def create
    @stock_watch = Warbler::StockWatch.new permitted_params
    authorize! :create, @stock_watch
    flag = @stock_watch.save
    if flag
      flash[:notice] = 'Created stock watch.'
    else
      flash[:alert] = "Cannot create stock watch: #{@stock_watch.errors.messages}"
    end
    redirect_to :action => 'index'
  end

  def destroy
    @w = Warbler::StockWatch.find params[:id]
    authorize! :destroy, @w
    flag = @w.destroy
    if flag
      flash[:notice] = 'Success.'
    else
      flash[:alert] = @w.errors.messages
    end
    redirect_to action: 'index'
  end

  def index
    authorize! :index, Warbler::StockWatch
    @profiles = Ish::UserProfile.all
    @stock_watches = Warbler::StockWatch.order_by( ticker: :asc, direction: :asc, price: :desc
      ).includes( :profile )
    @stock_watch = Warbler::StockWatch.new
    @option_watches = Warbler::OptionWatch.order_by( ticker: :asc, direction: :asc, price: :desc ).includes( :profile )
    @option_watch = Warbler::OptionWatch.new
  end

  def update
    @stock_watch = Warbler::StockWatch.find params[:id]
    authorize! :update, @stock_watch
    flag = @stock_watch.update_attributes permitted_params
    if flag
      flash[:notice] = 'Updated stock watch.'
    else
      flash[:alert] = "Cannot update stock watch: #{@stock_watch.errors.messages}"
    end
    redirect_to :action => 'index'
  end

  private

  def permitted_params
    params[:warbler_stock_watch].permit!
  end

end



