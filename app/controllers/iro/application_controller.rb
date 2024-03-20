
Pu  ||= Iro::Purse
Str ||= Iro::Strategy
Po  ||= Iro::Position
O   ||= Iro::Option
Sto ||= Iro::Stock

class Iro::ApplicationController < Wco::ApplicationController
  layout 'iro/application'

  before_action :set_lists

  def home
    authorize! :home, Iro
  end

  ##
  ## private
  ##
  private

  def set_lists
    @purses = Iro::Purse.all
    @strategies = Iro::Strategy.all
  end


end
