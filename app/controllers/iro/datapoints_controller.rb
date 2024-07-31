
class Iro::DatapointsController < Iro::ApplicationController

  ## params: d, k, v
  def create
    authorize! :create, Iro::Datapoint
    begin
      Iro::Datapoint.create!(
        date:  params[:d],
        kind:  params[:k],
        value: params[:v],
      )
      render json: { status: :ok }
    rescue Mongoid::Errors::Validations => e
      render json: { status: 401 }, status: 401
    end
  end

  def index
    authorize! :datapoints_index, Iro
    @symbol = params[:symbol] || params[:q]
    @datapoints = Iro::Datapoint.where( symbol: @symbol ).order_by( quote_at: :desc ).limit(100)
  end

end
