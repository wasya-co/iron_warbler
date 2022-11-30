
require "iron_warbler/engine"
require 'iron_warbler/railtie' if defined?(Rails)
require 'iron_warbler/configuration'

module Iwa
end

module Tda
end

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

##
## Must come after above module definitions
##
require 'tda/option_criteria'
require 'tda/option'
require 'tda/trade'
# require 'iwa'
require 'iwa/input_error'
require 'iwa/purse'
# require 'iwa/option_watch'
require 'iwa/runner'
# require 'app/models/iron_warbler/option_price_item'

