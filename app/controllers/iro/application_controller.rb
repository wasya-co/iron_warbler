
Pu  ||= Iro::Purse
Str ||= Iro::Strategy
Po  ||= Iro::Position
O   ||= Iro::Option
Sto ||= Iro::Stock

class Iro::ApplicationController < Wco::ApplicationController
  layout 'iro/application'

  before_action :set_lists, except: %i| schwab_sync |
  before_action :set_vcfg

  def home
    authorize! :home, Iro
  end

  def schwab_sync
    authorize! :schwab_sync, Iro
    render json: Iro::Iro.schwab_sync
  end

  def schwab_sync_exec
    authorize! :schwab_sync_exec, Iro
    render json: Iro::Iro.schwab_sync_exec
  end

  ##
  ## private
  ##
  private

  def set_lists
    @purses = Iro::Purse.all.order_by( slug: :asc )
  end

  def set_vcfg
    params[:vcfg] ||= {
      statuses: [ 'active', 'pending' ],
      template: Iro::Purse::TEMPLATE_GAMEUI,
    }
    params[:vcfg].permit!
  end


end
