
class IshManager::OptionWatchesController < IshManager::ApplicationController

  layout 'ish_manager/application2'

  ## alphabetized : )

  def create
    @option_watch = Warbler::OptionWatch.new permitted_params
    authorize! :create, @option_watch
    flag = @option_watch.save
    if flag
      flash[:notice] = 'Created option watch.'
    else
      flash[:alert] = "Cannot create option watch: #{@option_watch.errors.messages}"
    end
    redirect_to controller: 'stock_watches', action: 'index'
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
    redirect_to controller: 'stock_watches', action: 'index'
  end

  def index
    authorize! :open_permission, IshManager::Ability
    flash[:notice] = 'Redirected option->stock watch index'
    # redirect_to controller: IshManager::StockWatchesController, action: 'index'
    redirect_to controller: 'stock_watches', action: 'index'
  end

  def update
    @option_watch = Warbler::OptionWatch.find params[:id]
    authorize! :update, @option_watch
    flag = @option_watch.update_attributes permitted_params
    if flag
      flash[:notice] = 'Updated option watch.'
    else
      flash[:alert] = "Cannot update option watch: #{@option_watch.errors.messages}"
    end
    redirect_to controller: 'stock_watches', action: 'index'
  end

  private

  def permitted_params
    params[:warbler_option_watch].permit!
  end

end



