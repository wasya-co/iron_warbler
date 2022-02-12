require 'spec_helper'

describe IronWarbler::Api::StockWatchesController, type: :controller do
  render_views
  routes { IronWarbler::Engine.routes }

  before do
  end

  it '#index' do
    create(:stock_watch)
    get :index
    response.should be_success
  end

end
