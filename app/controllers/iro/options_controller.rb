
class Iro::OptionsController < Iro::ApplicationController

  def index
    authorize! :index, Iro::Option
    @options = Iro::Option.active

  end


  def show
    @option = Iro::Option.find params[:id]
    authorize! :show, @option
  end

end

