
RSpec.describe Iro::PursesController do
  render_views
  routes { Iro::Engine.routes }

  before do
    setup_users
    do_iro_setup_1
  end

  it '#show' do
    get :show, params: { id: @purse.id }
    response.code.should eql '200'
  end

end

