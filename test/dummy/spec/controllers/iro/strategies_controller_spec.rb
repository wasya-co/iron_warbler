
RSpec.describe Iro::StrategiesController do
  render_views
  routes { Iro::Engine.routes }

  before do
    setup_users
    destroy_every( Iro::Strategy )
    @strategy = create(:strategy)
  end

  it '#new' do
    get :new
    response.code.should eql '200'
  end

  it '#show' do
    get :show, params: { id: @strategy.id }
    response.code.should eql '200'
  end

end
