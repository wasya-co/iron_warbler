
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
    # from = '2023-12-20'
    # to = '2023-12-01'
    # points = Iro::Datapoint.where( k: params[:k] ).joins( :dates )

    sql = "SELECT
      dps.k, dps.v, d.date
    FROM
      iro_datapoints as dps
      RIGHT JOIN dates d ON d.date = dps.d WHERE d.date BETWEEN '2023-12-01' AND '2023-12-31'
    ORDER BY
      d.date;"

    # outs = ActiveRecord::Base.connection.execute(sql)
    # puts! outs, 'outs'

    render json: outs

  end

end
