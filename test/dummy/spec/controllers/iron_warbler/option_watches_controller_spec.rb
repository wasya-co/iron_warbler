require 'spec_helper'

## @TODO: this too should be moved into warbler gem
describe IshManager::OptionWatchesController, :type => :controller do
  render_views
  routes { IshManager::Engine.routes }

  before :each do
    setup_users
  end

  it '#index' do
    get :index
    response.should redirect_to( controller: 'stock_watches' )
  end

  it '#create' do
    expect do
      post :create, params: { warbler_option_watch: build(:option_watch).attributes }
    end.to change { Warbler::OptionWatch.count }.by( 1 )
  end

  it '#update' do
    a = create(:option_watch, price: 100 )
    post :update, params: { id: a.id, warbler_option_watch: { price: 99 } }
    a.reload.price.should eql 99.0
  end

end
