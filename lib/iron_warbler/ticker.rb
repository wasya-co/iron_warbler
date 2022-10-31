
class IronWarbler::Ticker < ActiveRecord::Base
  # include Mongoid::Document
  # include Mongoid::Timestamps
  # store_in collection: 'ish_tickers'

  field :ticker
  validates_presence_of :ticker

  # @TODO: wire paranoia, deleted_at field

  def self.active
    self.all
  end

end
