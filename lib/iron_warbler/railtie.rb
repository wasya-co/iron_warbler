require 'rails'

module IronWarbler
  class Railtie < Rails::Railtie
    initializer "iron_warbler.configure" do |app|
    end
  end
end