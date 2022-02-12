
class IronWarbler::StockWatchesController < IronWarbler::ApplicationController

  ## alphabetized : )

  def create
    @stock_watch = IronWarbler::StockWatch.new permitted_params
    authorize! :create, @stock_watch
    flag = @stock_watch.save
    if flag
      flash[:notice] = 'Created stock watch.'
    else
      flash[:alert] = "Cannot create stock watch: #{@stock_watch.errors.full_messages}"
    end
    redirect_to :action => 'index'
  end

  def destroy
    @w = IronWarbler::StockWatch.find params[:id]
    authorize! :destroy, @w
    flag = @w.destroy
    if flag
      flash[:notice] = 'Success.'
    else
      flash[:alert] = @w.errors.full_messages
    end
    redirect_to action: 'index'
  end

  def index
    authorize! :index, IronWarbler::StockWatch
    @stock_watches = IronWarbler::StockWatch.order_by( ticker: :asc, direction: :asc, price: :desc
      ).includes()
    @stock_watch = IronWarbler::StockWatch.new
    @option_watches = IronWarbler::OptionWatch.order_by( ticker: :asc, direction: :asc, price: :desc ).includes()
    @option_watch = IronWarbler::OptionWatch.new
    @profiles = [
      { email: 'piousbox@gmail.com', id: 'piousbox@gmail.com' }.with_indifferent_access
    ]
  end

  def update
    @stock_watch = IronWarbler::StockWatch.find params[:id]
    authorize! :update, @stock_watch
    flag = @stock_watch.update_attributes permitted_params
    if flag
      flash[:notice] = 'Updated stock watch.'
    else
      flash[:alert] = "Cannot update stock watch: #{@stock_watch.errors.full_messages}"
    end
    redirect_to :action => 'index'
  end

  private

  def permitted_params
    params[:stock_watch].permit!
  end

end



