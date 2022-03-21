
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'devise'
require 'shoulda/matchers'

ActiveSupport::Deprecation.silenced = true

## From: https://github.com/DatabaseCleaner/database_cleaner-mongoid
DatabaseCleaner.clean

module Ish
end

def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end

RSpec.configure do |config|

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  config.include FactoryBot::Syntax::Methods

  ## 20210205
  config.include Rails.application.routes.url_helpers
  config.include Warden::Test::Helpers
  Warden.test_mode!

  config.infer_spec_type_from_file_location!

  # config.include Devise::TestHelpers, :type => :helper
  # config.include Devise::TestHelpers, :type => :controller
  config.include Devise::Test::ControllerHelpers, :type => :controller

end

##
## Cannot be alphabetized!
##
def do_setup
end

def setup_users
  @admin = @user = create(:user, :email => 'piousbox@gmail.com', profile: create(:profile))

  @manager = create(:user, email: 'manager@gmail.com', profile: create(:profile))

  @guy = @user_1  = create :user, :email => 'guy@gmail.com', profile: create(:profile)

  @user_2  = create :user, :email => 'user-2@gmail.com', profile: create(:profile)

  sign_in @user, :scope => :user
end

Paperclip.options[:log] = false

# jwt
def encode(payload, exp = 2.hours.from_now)
  payload[:exp] = exp.to_i
  JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)
end
