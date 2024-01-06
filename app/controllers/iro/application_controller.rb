

class Iro::ApplicationController < Wco::ApplicationController
  layout 'iro/application'

  def home
    authorize! :home, Iro
  end

end
