
require "iron_warbler/engine"
require 'iron_warbler/railtie' if defined?(Rails)
require 'iron_warbler/configuration'

module IronWarbler

  CALL = :CALL
  PUT  = :PUT

  INTERVAL_5_SECONDS = 5
  INTERVAL_1_MINUTE_SECONDS = 60
  INTERVAL_5_MINUTES_SECONDS = 300

  class << self
    attr_accessor :configurationx
  end

  def self.configure
    @configuration ||= Configuration.new
  end

  def self.setup
    yield(configuration)
  end
end


require 'iron_warbler/ameritrade'

require 'iron_warbler/option_price_item'
require 'iron_warbler/option_watch'

# require 'app/controllers/iron_warbler/application_controller'
# require 'app/controllers/iron_warbler/option_watches_controller'
# require 'app/controllers/iron_warbler/api_controller'
# require 'app/controllers/iron_warbler/api/option_price_items_controller'
# require 'app/controllers/iron_warbler/api/option_watches_controller'


