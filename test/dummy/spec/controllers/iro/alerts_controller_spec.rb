
RSpec.describe Iro::AlertsController do
  render_views
  routes { Iro::Engine.routes }

  before do
    destroy_every( Iro::Alert, Iro::Stock )
    qqq = create( :stock )
    setup_users

    @alert = create( :alert )
  end

  describe '#index' do
    it 'assigns for #new' do
      get :index
      response.code.should eql '200'
      assigns( :stocks_list ).length.should > 1 # not only nil
      assigns( :alerts ).length.should > 0
    end
  end

end
