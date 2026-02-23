
RSpec.describe Iro::StocksController do
  render_views
  routes { Iro::Engine.routes }

  before do
    setup_users
  end

  describe 'positive' do
    it '#index' do
      get :index
      response.code.should eql '200'
    end

    it '#show' do
      stock = create(:stock, ticker: 'TSLA')
      get :show, params: { id: stock.id }
      response.code.should eql '200'
    end
  end

  # describe 'negative' do
  #   it '#create' do
  #     post :create, params: { time: Time.now, value: 2 }
  #     response.code.should eql '401'
  #   end
  # end

end
