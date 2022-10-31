
class IronWarbler::OptionWatchesController < IronWarbler::ApplicationController

  def create
    ow = IronWarbler::OptionWatch.new params[:option_watch].permit!
    if ow.save
      flash[:notice] = 'Success'
    else
      flash[:alert] = "No Luck: #{ow.errors.full_messages.join(', ')}"
    end
    redirect_to action: :index
  end

  def index
    @option_watches = IronWarbler::OptionWatch.all
    @new_option_watch = IronWarbler::OptionWatch.new
  end

  def update
    ow = IronWarbler::OptionWatch.find params[:id]
    flag = ow.update params[:option_watch].permit!
    if flag
      flash[:notice] = 'Success'
    else
      flash[:alert] = "No Luck: #{ow.errors.full_messages.join(', ')}"
    end
    redirect_to action: :index
  end

end


