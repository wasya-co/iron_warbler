
require_dependency "iron_warbler/api_controller"

class IronWarbler::Api::StockWatchesController < IronWarbler::ApiController

  before_action :check_profile_auth

  # alphabetized : )

  def create
    @stock_watch = IronWarbler::StockWatch.new permitted_params
    authorize! :create, @stock_watch
    flag = @stock_watch.save
    if flag
      render json: { message: 'Created stock watch.' }, status: :ok
    else
      render json: { message:
        "Cannot create stock watch: #{@stock_watch.errors.full_messages.join(", ")}."
      }, status: 422
    end
  ## @TODO: have only one such rescue.
  rescue CanCan::AccessDenied => e
    render json: { code: 401, message: 'unauthorized request' }, status: 401
    return
  end

  ## only shows mine
  def index
    authorize! :index, IronWarbler::StockWatch
    @stock_watches = IronWarbler::StockWatch.active_for(current_user.profile)
    puts! @stock_watches.to_a, '@stock_watches'
    puts! current_user.profile.id, 'p_id'
  rescue CanCan::AccessDenied => e
    render json: { code: 401, message: 'unauthorized request' }, status: 401
    return
  end

  private

  def permitted_params
    puts! params[:stock_watch], 'params[:stock_watch]'
    params[:stock_watch].permit(%i| action direction price profile_id ticker |)
  end


end
