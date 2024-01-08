
class Iro::DatapointsController < Iro::ApplicationController

  ## params: d, k, v
  def create
    begin
      Iro::Datapoint.create( k: params[:k], v: params[:v], created_at: params[:time] )
      render json: { status: :ok }
    rescue ActiveRecord::NotNullViolation => exception
      render json: { status: :unauthorized }, status: :unauthorized
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

    outs = ActiveRecord::Base.connection.execute(sql)
    puts! outs, 'outs'

    render json: outs

  end

end
