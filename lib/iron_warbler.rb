require "iron_warbler/engine"

require 'iron_warbler/railtie' if defined?(Rails)
require 'iron_warbler/configuration'

# ::S3_CREDENTIALS ||= {}

module IronWarbler

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

