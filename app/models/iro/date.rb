
class Iro::Date
  include Mongoid::Document
  # include Mongoid::Timestamps
  store_in collection: 'iro_dates'

  field :date

end

