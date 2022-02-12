require 'spec_helper'

describe IronWarbler::Api::StockWatchesController, type: :controller do
  render_views
  routes { IronWarbler::Engine.routes }

  # let('current_user') { create(:user, email: 'piousbox@gmail.com') }
  let('user_1') { create(:user) }

  before do
    @u = create(:user, email: 'piousbox@gmail.com')
    # IronWarbler::Api::StockWatchesController.instance_variable_set(:@current_user, current_user)
    # IronWarbler::Api::StockWatchesController.any_instance.stub(:current_ability).and_return(IronWarbler::Ability.new( current_user ))
    IronWarbler::Api::StockWatchesController.any_instance.stub(:current_user).and_return(@u)
    @sw_mine = create(:stock_watch, profile: @u.profile )
    @sw_1 = create(:stock_watch, profile: user_1.profile )
  end

  it '#index' do
    get :index, format: :json
    puts!(response.body, 'cannot #index stock watches') if !response.successful?
    response.code.should eql '200' # 'cause #be_success don't work here right now...
    results = assigns(:stock_watches)
    results.include?(@sw_1).should eql false
    results.include?(@sw_mine).should eql true
  end

end
