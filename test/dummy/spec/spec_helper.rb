
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

RSpec.configure do |config|

  config.fixture_path = Rails.root.join('spec/fixtures')
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.include Devise::TestHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods

end

def destroy_every *args
  args.each do |arg|
    arg.unscoped.map &:destroy!
  end
end

def setup_users
  User.all.destroy_all
  user = User.create!( email: 'victor@wasya.co', password: 'test1234', provider: 'keycloakopenid' )
  Wco::Profile.unscoped.map &:destroy!
  p = Wco::Profile.create!( email: user.email )
  sign_in user
end

EPSILON = 0.01
