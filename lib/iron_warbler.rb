
require 'business_time'
require 'haml'
require 'mongoid'

require "iro/engine"

class Iro::Iro

  def self.get_coins
    out = HTTParty.get( "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest?slug=bitcoin,ethereum", {
      headers: { 'X-CMC_PRO_API_KEY' => COINMARKETCAP[:key] },
    })
    out = out.parsed_response.deep_symbolize_keys
    out[:data].each do |k, item|
      opi = Iro::Datapoint.new({
        kind:     Iro::Datapoint::KIND_CRYPTO,
        symbol:   item[:symbol],
        quote_at: item[:quote][:USD][:last_updated],
        value:    item[:quote][:USD][:price],
        volume:   item[:quote][:USD][:volume_24h],
      })
      opi.save!
    end
  end

end
