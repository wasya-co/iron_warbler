
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

def do_iro_setup_1
  destroy_every(
    Iro::Option,
    Iro::Position, Iro::Purse,
    Iro::Stock,    Iro::Strategy,
  );
  @stock_meta = create(:stock_meta)
  @strategy   = create(:strategy_long_credit_put_spread, stock: @stock_meta)
  @purse      = create(:purse, )
  @inner      = create(:option)
  @outer      = create(:option)
  @position   = create(:position, strategy: @strategy, inner: @inner, outer: @outer )

end


def setup_users

  User.all.destroy_all
  user = User.create!( email: 'victor@wasya.co', password: 'test1234', provider: 'keycloakopenid' )

  Wco::Leadset.unscoped.map &:destroy!
  leadset = create( :leadset )

  Wco::Profile.unscoped.map &:destroy!
  p = Wco::Profile.create!( email: user.email, leadset: leadset )

  sign_in user
end

EPSILON = 0.0001
