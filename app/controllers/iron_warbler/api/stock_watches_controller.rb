
require_dependency "iron_warbler/api/api_controller"

class IronWarbler::Api::StockWatchesController < IronWarbler::Api::ApiController

  before_action :check_profile_auth

  ## only shows mine
  def index
    authorize! :index, IronWarbler::StockWatch
    @stock_watches = IronWarbler::StockWatch.active_for(current_user.profile)
  end

end

