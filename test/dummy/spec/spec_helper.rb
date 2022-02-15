
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'devise'

ActiveSupport::Deprecation.silenced = true

## From: https://github.com/DatabaseCleaner/database_cleaner-mongoid
DatabaseCleaner.clean

def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end

RSpec.configure do |config|

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
  @admin = @user = create(:user, :email => 'piousbox@gmail.com')

  @manager = create(:user, email: 'manager@gmail.com')

  @guy = @user_1  = create :user, :email => 'guy@gmail.com'

  @user_2  = create :user, :email => 'user-2@gmail.com'

  sign_in @user, :scope => :user
end

Paperclip.options[:log] = false
