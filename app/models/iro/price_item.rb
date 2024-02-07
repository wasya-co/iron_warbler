
class Iro::PriceItem
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_price_items'

  field :putCall,         type: String
  field :symbol,          type: String
  field :ticker,          type: String

  field :bid,             type: Float
  field :bidSize,         type: Integer
  field :ask,             type: Float
  field :askSize,         type: Integer
  field :last,            type: Float

  field :openPrice,       type: Float
  field :closePrice,      type: Float
  field :lowPrice,        type: Float
  field :highPrice,       type: Float

  field :quoteTimeInLong, type: Integer
  field :timestamp,       type: Integer
  field :totalVolume,     type: Integer
  field :mark,            type: Float
  field :exchangeName,    type: String
  field :volatility,      type: Float

end
