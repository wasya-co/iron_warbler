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

Rails.backtrace_cleaner.remove_silencers! if ENV["BACKTRACE"]
Rails.application.config.action_dispatch.cookies_serializer = :json

ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :patch, :put]
  end
end

Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
