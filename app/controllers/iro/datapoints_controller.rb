require_dependency "iro/application_controller"

class Iro::DatapointsController < ApplicationController

  ## params: key, time, value
  def create
    begin
      Iro::Datapoint.create( key: params[:key], value: params[:value], created_at: params[:time] )
      render json: { status: :ok }
    rescue ActiveRecord::NotNullViolation => exception
      render json: { status: :unauthorized }, status: :unauthorized
    end
  end

  def index
    # from = '2023-12-20'
    # to = '2023-12-01'
    # points = Iro::Datapoint.where( key: params[:key] ).joins( :dates )

    sql = "SELECT
      dps.k, dps.v, d.date
    FROM
      iro_datapoints as dps
      RIGHT JOIN dates d ON d.date = dps.d WHERE d.date BETWEEN '2023-12-01' AND '2023-12-31'
    ORDER BY
      d.date;"

    outs = ActiveRecord::Base.connection.execute(sql)
    puts! outs, 'outs'

    render json: outs

  end

end
