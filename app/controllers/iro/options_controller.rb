
class Iro::OptionsController < Iro::ApplicationController

  def index
    authorize! :index, Iro::Option
    @options = Iro::Option.active

  end


  def show
  end

end

