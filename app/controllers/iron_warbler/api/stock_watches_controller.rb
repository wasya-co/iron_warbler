
require_dependency "iron_warbler/api/api_controller"

class IronWarbler::Api::StockWatchesController < IronWarbler::Api::ApiController

  before_action :check_profile_auth

  def index
    authorize! :index, IronWarbler::StockWatch
    @stock_watches = IronWarbler::StockWatch.active # @TODO: restrict by profile
  end

end

