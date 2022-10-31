
class IronWarbler::Api::OptionPriceItemsController < IronWarbler::ApiController

  ## alphabetized : )

  def index
    authorize! :open_permission, IronWarbler::Ability
    from_date = params[:from_date]
    to_date   = params[:to_date]
    symbol    = params[:symbol]
    @opis = IronWarbler::OptionPriceItem.all(
    ).where(
      'timestamp >= ?', from_date
    ).where(
      'timestamp <= ?', 1.day.after(Date.parse(to_date))
    ).where(
      symbol: symbol
    ).limit(1000) # @TODO: remove the limit
  end

  def meta_by_symbol
    authorize! :open_permission, IronWarbler::Ability
    symbol = params[:symbol]

    @max_date = IronWarbler::OptionPriceItem.where(symbol: symbol).order(timestamp: :desc).limit(1).first.timestamp
    @min_date = IronWarbler::OptionPriceItem.where(symbol: symbol).order(timestamp: :asc).limit(1).first.timestamp

    render 'meta'
  end

  def search
    authorize! :open_permission, IronWarbler::Ability
    q = params[:q]

    @symbols = IronWarbler::OptionPriceItem.where("symbol ILIKE ?", "%#{q}%").select(:symbol).distinct
  end

  private

end



