require 'spec_helper'

## @TODO: this too should be moved into warbler gem
describe IronWarbler::Api::OptionWatchesController, :type => :controller do
  render_views
  routes { IronWarbler::Engine.routes }

  ## @TODO: this is duplicated in stock_watches_controller_spec
  let('cu') { create(:user, email: 'piousbox@gmail.com') }
  let('user_1') { create(:user) }

  before :each do
    IronWarbler::Api::OptionWatchesController.any_instance.stub(:current_user).and_return(cu)
  end

  it '#index' do
    get :index
    response.should redirect_to( controller: 'stock_watches' )
  end

  it '#create' do
    expect do
      post :create, params: { warbler_option_watch: build(:option_watch).attributes }
    end.to change { IronWarbler::OptionWatch.count }.by( 1 )
  end

  it '#update' do
    a = create(:option_watch, price: 100 )
    post :update, params: { id: a.id, warbler_option_watch: { price: 99 } }
    a.reload.price.should eql 99.0
  end

end
