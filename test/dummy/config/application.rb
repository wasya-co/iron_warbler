require_relative "boot"

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

require 'devise'

Bundler.require(*Rails.groups)

require "iron_warbler"


module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
  end
end

def puts! a, b=''
  puts "+++ +++ #{b}:"
  puts a.inspect
end
