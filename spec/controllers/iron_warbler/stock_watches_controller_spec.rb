require 'spec_helper'

## @TODO: this too should be moved into warbler gem
describe IshManager::StockWatchesController, :type => :controller do
  render_views
  routes { IshManager::Engine.routes }

  before :each do
    setup_users
  end

  it '#index' do
    get :index
    response.should be_success

    assigns(:option_watches).should_not eql nil
    assigns(:stock_watches).should_not eql nil
    assigns(:option_watch).should_not eql nil
    assigns(:stock_watch).should_not eql nil
  end

  it '#create' do
    expect do
      post :create, params: { warbler_stock_watch: build(:stock_watch).attributes }
    end.to change { Warbler::StockWatch.count }.by( 1 )
  end

  it '#update' do
    a = create(:stock_watch, price: 100 )
    post :update, params: { id: a.id, warbler_stock_watch: { price: 99 } }
    a.reload.price.should eql 99.0
  end

end
