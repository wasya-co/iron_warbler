require 'spec_helper'

describe IronWarbler::Api::OptionPriceItemsController, type: :controller do
  render_views
  routes { IronWarbler::Engine.routes }

  let('current_user') { create(:user, email: 'piousbox@gmail.com') }
  let('user_1') { create(:user) }

  before do
    ## Not using devise b/c this uses JWT
    IronWarbler::Api::StockWatchesController.any_instance.stub(:current_user).and_return(current_user)
  end

  it '#index' do
    opi = create(:opi, symbol: 'GME_031822P75', timestamp: '2022-02-02' )

    get :index, format: :json, params: { symbol: 'GME_031822P75',
      from_date: '2022-02-01', to_date: '2022-02-20' }

    puts!(response.body, 'cannot #index option_price_items') if !response.successful?
    response.code.should eql '200' # 'cause #be_success don't work here right now...
    results = assigns(:opis)
    results.length.should > 0
  end

end

