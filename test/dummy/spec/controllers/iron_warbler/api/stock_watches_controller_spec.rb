require 'spec_helper'

describe IronWarbler::Api::StockWatchesController, type: :controller do
  render_views
  routes { IronWarbler::Engine.routes }

  let('cu') { create(:user, email: 'piousbox@gmail.com') }
  let('user_1') { create(:user) }

  before do
    ## Not using devise b/c this uses JWT
    IronWarbler::Api::StockWatchesController.any_instance.stub(:current_user).and_return(cu)
    @sw_mine = create(:stock_watch, profile: cu.profile )
    @sw_1 = create(:stock_watch, profile: user_1.profile )
  end

  it '#create' do
    expect do
      post :create, params: { warbler_stock_watch: build(:stock_watch).attributes }
    end.to change { IronWarbler::StockWatch.count }.by( 1 )
  end

  it '#index' do
    get :index, format: :json
    puts!(response.body, 'cannot #index stock watches') if !response.successful?
    response.code.should eql '200' # 'cause #be_success don't work here right now...
    results = assigns(:stock_watches)
    results.include?(@sw_1).should eql false
    results.include?(@sw_mine).should eql true

    assigns(:option_watches).should_not eql nil
    assigns(:stock_watches).should_not eql nil
    assigns(:option_watch).should_not eql nil
    assigns(:stock_watch).should_not eql nil
  end

  it '#update' do
    a = create(:stock_watch, price: 100 )
    post :update, params: { id: a.id, warbler_stock_watch: { price: 99 } }
    a.reload.price.should eql 99.0
  end

end

