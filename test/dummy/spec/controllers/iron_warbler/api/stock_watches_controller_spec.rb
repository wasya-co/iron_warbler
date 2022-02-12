require 'spec_helper'

describe IronWarbler::Api::StockWatchesController, type: :controller do
  render_views
  routes { IronWarbler::Engine.routes }

  let('current_user') { create(:admin) }

  before do
  end

  it '#index' do
    # IronWarbler::Api::StockWatchesController.instance_variable_set(:@current_user, current_user)
    # IronWarbler::Api::StockWatchesController.any_instance.stub(:current_ability).and_return(IronWarbler::Ability.new( current_user ))
    IronWarbler::Api::StockWatchesController.any_instance.stub(:current_user).and_return(current_user)
    create(:stock_watch)
    get :index
    response.should be_success
  end

end
