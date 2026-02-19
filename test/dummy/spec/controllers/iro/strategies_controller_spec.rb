
RSpec.describe Iro::StrategiesController do
  render_views
  routes { Iro::Engine.routes }

  before do
    setup_users

    destroy_every(
      Iro::Option,
      Iro::Position, Iro::Purse,
      Iro::Stock,    Iro::Strategy,
    );
    @stock_meta = create(:stock, ticker: 'META')
    @strategy   = create(:strategy_long_credit_put_spread, stock: @stock_meta)
    @purse      = create(:purse )
  end

  it '#edit' do
    get :edit, params: { id: @strategy.id }
    response.code.should eql '200'
  end

  it '#new, long put spread' do
    get :new, params: { kind: Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD }
    response.code.should eql '200'
    # puts! response.body, 'response.body'
    expect(response.body).to include('strategies--form')
  end

  it '#new, short call spread' do
    get :new, params: { kind: Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD }
    response.code.should eql '200'
    # puts! response.body, 'response.body'
    expect(response.body).to include('strategies--form')
  end

  it '#show' do
    get :show, params: { id: @strategy.id }
    response.code.should eql '200'
  end

end
