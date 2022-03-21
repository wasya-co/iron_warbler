require 'spec_helper'

describe IronWarbler::Api::StockWatchesController, type: :controller do
  render_views
  routes { IronWarbler::Engine.routes }

  let('current_user') { create(:user, email: 'piousbox@gmail.com', profile: create(:profile)) }
  let('user_1') { create(:user, profile: create(:profile)) }

  before do
    @sw_mine = create(:stock_watch, profile: current_user.profile )
    @sw_1    = create(:stock_watch, profile: user_1.profile )

    @jwt_token = encode({ user_id: current_user.id })
  end

  skip '#create' do
    expect do
      post :create, params: { warbler_stock_watch: build(:stock_watch).attributes }
    end.to change { IronWarbler::StockWatch.count }.by( 1 )
  end

  skip '#index' do
    get :index, format: :json, params: { jwt_token: @jwt_token }
    puts!(response.body, 'cannot #index stock watches') if !response.successful?
    response.code.should eql '200' # 'cause #be_success don't work here right now...
    results = assigns(:stock_watches)
    results.include?(@sw_1).should eql false
    results.include?(@sw_mine).should eql true

    assigns(:stock_watches).should_not eql nil
    sw = assigns(:stock_watches)[0]
    fields = %i| action direction price profile_id ticker |
    fields.each do |field|
      sw[field].should_not eql(nil), "#{field} missing from response"
    end
  end

  skip '#update' do
    a = create(:stock_watch, price: 100, profile: current_user.profile )
    post :update, params: { id: a.id, jwt_token: @jwt_token,
      warbler_stock_watch: { price: 99 } }
    a.reload.price.should eql 99.0
  end

end

