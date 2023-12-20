
RSpec.describe Iro::StocksController, type: :controller do
  render_views
  routes { Iro::Engine.routes }
  # include Devise::Test::ControllerHelpers

  describe 'positive' do
    it '#index' do
      get :index
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
