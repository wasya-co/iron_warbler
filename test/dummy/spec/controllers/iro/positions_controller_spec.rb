
RSpec.describe Iro::PositionsController do
  render_views
  routes { Iro::Engine.routes }

  before do
    setup_users
    do_iro_setup_1
  end

  describe '#prepare' do
    it 'prepare_long_credit_put_spread' do
      get :prepare, params: { id: @position.id }
      response.code.should eql '200'
    end
  end

  describe '#update' do
    it 'updates inner begin_price, begin_delta' do
      pos = create( :position,
        inner: create(:option, begin_price: 0.99, begin_delta: 0.2),
        outer: create(:option) )
      post :update, params: { id: pos.id, position: { expires_on: pos.expires_on },
        inner: { begin_price: 2.01, begin_delta: 0.33 },
        outer: { begin_price: pos.outer.begin_price } }
      pos.reload
      pos.inner.begin_price.should eql 2.01
      pos.inner.begin_delta.should eql 0.33
    end
  end

end
