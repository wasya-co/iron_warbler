
RSpec.describe Iro::PursesController do
  render_views
  routes { Iro::Engine.routes }

  before do
    destroy_every(
      Iro::Option,
      Iro::Position, Iro::Purse,
      Iro::Stock, Iro::Strategy )
    setup_users
    @stock = create(:stock)
    @strategy = create(:strategy, stock: @stock)
    @purse = create(:purse, stock: @stock)
    @position = create(:position, inner: create(:option), outer: create(:option) )
  end

  it '#show' do
    get :show, params: { id: @purse.id }
    response.code.should eql '200'
  end

end

