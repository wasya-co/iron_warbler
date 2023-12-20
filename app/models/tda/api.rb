
require 'httparty'

class Tda::Api
  include ::HTTParty
  base_uri 'https://api.tdameritrade.com'

  ## alias
  def self.get_quote which
    self.get_quotes( which )[0]
  end

  ## tickers = "GME"
  ## tickers = "NVDA,GME"
  def self.get_quotes tickers
    path = "/v1/marketdata/quotes"
    inns = self.get path, { query: { apikey: ::TD_AMERITRADE[:apiKey], symbol: tickers } }
    inns = inns.parsed_response
    inns.each do |k, v|
      inns[k] = v.deep_symbolize_keys
    end
    outs = []
    inns.each do |symbol, obj|
      outs.push ::Iro::PriceItem.create!({
        putCall:        'STOCK',
        symbol:          symbol,
        ticker:          symbol,
        bid:             obj[:bidPrice],
        bidSize:         obj[:bidSize],
        ask:             obj[:askPrice],
        askSize:         obj[:askSize],
        last:            obj[:lastPrice],
        openPrice:       obj[:openPrice],
        closePrice:      obj[:closePrice],
        highPrice:       obj[:highPrice],
        lowPrice:        obj[:lowPrice],
        quoteTimeInLong: obj[:quoteTimeInLong],
        timestamp:       Time.at( obj[:quoteTimeInLong]/1000 ),
        totalVolume:     obj[:totalVolume],
        mark:            obj[:mark],
        exchangeName:    obj[:exchangeName],
        volatility:      obj[:volatility],
      })
    end
    return outs
  end

end