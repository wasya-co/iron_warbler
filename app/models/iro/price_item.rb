
class Iro::PriceItem
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_price_items'

end
