
RSpec.describe Iro::StocksController do
  render_views
  routes { Iro::Engine.routes }

  before do
    setup_users
    destroy_every(
      Iro::Datapoint,
      Iro::Stock,
    );
    @stock       = create(:stock, ticker: 'TSLA')
    @datapoint   = create(:datapoint, date: '2026-01-01', symbol: @stock.ticker, value: 100.0 )
    @datapoint_2 = create(:datapoint, date: '2026-01-02', symbol: @stock.ticker, value: 100.0 )
  end

  describe 'positive' do
    it '#index' do
      get :index
      response.code.should eql '200'
    end

    it '#show' do
      get :show, params: { id: @stock.id }
      response.code.should eql '200'
    end
  end

end
