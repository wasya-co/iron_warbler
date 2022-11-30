
class Tda::Trade

  def self.roll *args
    puts! args, 'Tda::Trade.roll'
  end

  # def self.place_stock_limit_order _opts
  #   opts = {
  #     "orderType": "LIMIT",
  #     "session": "NORMAL",
  #     "duration": "DAY",
  #     "orderStrategyType": "SINGLE",
  #     "orderLegCollection": [
  #       {
  #         "instrument": {
  #           "assetType": "EQUITY"
  #         }
  #       }
  #     ]
  #   }
  #
  #   valid_opts = %i| instruction price quantity symbol |
  #   if !(missing_opts = valid_opts - _opts.keys).blank?
  #     raise Iwa::InputError.new("Missing some inputs: #{missing_opts.join(', ')}.")
  #   end
  #   opts[:orderLegCollection][0][:instruction] = _opts[:instruction]
  #   opts[:price] = _opts[:price]
  #   opts[:orderLegCollection][0][:quantity] = _opts[:quantity]
  #   opts[:orderLegCollection][0][:instrument][:symbol] = _opts[:symbol]
  #
  #   query = { apikey: ::TD_AME[:apiKey] }.merge opts
  #   path = "/v1/accounts/#{account_id}/orders"
  #   out = self.post path, { query: query }
  #   out = out.parsed_response.deep_symbolize_keys
  #   out
  # end

end
