
class Iro::OptionsController < Iro::ApplicationController

  def index
    authorize! :index, Iro::Option
    @options = Iro::Option.active

  end


  def show
    @option = Iro::Option.find params[:id] if params[:id]
    @option = Iro::Option.find_by symbol: params[:symbol] if params[:symbol]
    authorize! :show, @option
  end

end

