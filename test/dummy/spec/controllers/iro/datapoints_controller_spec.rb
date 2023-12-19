

RSpec.describe Iro::DatapointsController, type: :controller do

  render_views
  routes { IronWarbler::Engine.routes }
  # include Devise::Test::ControllerHelpers

  describe 'positive' do
    it '#create' do
      n = Iro::Datapoint.all.count
      post :create, params: { key: 'a', time: Time.now, value: 2 }
      Iro::Datapoint.all.count.should eql( n + 1 )
    end
  end

  describe 'negative' do
    it '#create' do
      post :create, params: { time: Time.now, value: 2 }
      response.code.should eql '401'
    end
  end

end
