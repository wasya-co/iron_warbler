
RSpec.describe Iro::StrategiesController do
  render_views
  routes { Iro::Engine.routes }

  before do
    setup_users
    destroy_every( Iro::Stock, Iro::Strategy )
  end

  it '#edit' do
    @stock_meta = create(:stock_meta)
    @strategy = create(:strategy_long_credit_put_spread, stock: @stock_meta )
    get :edit, params: { id: @strategy.id }
    response.code.should eql '200'
  end

  it '#new' do
    get :new
    response.code.should eql '200'
  end

  it '#show' do
    @stock_meta = create(:stock_meta)
    @strategy = create(:strategy_long_credit_put_spread, stock: @stock_meta )
    get :show, params: { id: @strategy.id }
    response.code.should eql '200'
  end

end
