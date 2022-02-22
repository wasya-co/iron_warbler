
require "iron_warbler/engine"
require 'iron_warbler/railtie' if defined?(Rails)
require 'iron_warbler/configuration'

# ::S3_CREDENTIALS ||= {}

module IronWarbler

  CALL = :CALL
  PUT  = :PUT

  INTERVAL_1_MINUTE = '1-minute'
  INTERVAL_1_MINUTE_SECONDS = 60
  INTERVAL_5_MINUTES = '5-minutes'
  INTERVAL_5_MINUTES_SECONDS = 300
  INTERVALS = [ INTERVAL_1_MINUTE, INTERVAL_5_MINUTES ]

  class << self
    attr_accessor :configuration
  end

  def self.configure
    @configuration ||= Configuration.new
  end

  def self.setup
    yield(configuration)
  end
end


require 'iron_warbler/ameritrade'
require 'iron_warbler/asset_price_item'

require 'iron_warbler/option_price_item'
require 'iron_warbler/option_watch'

require 'iron_warbler/stock_watch'

require 'iron_warbler/ticker'

