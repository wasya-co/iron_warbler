

class Iro::Option
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'iro_options'

  # field :ticker
  # validates :ticker, uniqueness: true, presence: true

  field :symbol
  validates :symbol, uniqueness: true, presence: true


end
