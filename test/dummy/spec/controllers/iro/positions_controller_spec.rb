
RSpec.describe Iro::PositionsController do
  render_views
  routes { Iro::Engine.routes }

  before do
    setup_users

    destroy_every(
      Iro::Option,
      Iro::Position, Iro::Purse,
      Iro::Stock,    Iro::Strategy,
    );
    @stock_meta = create(:stock, ticker: 'META', options_price_increment: 5.0 )
    @strategy   = create(:strategy_long_credit_put_spread, stock: @stock_meta)
    @purse      = create(:purse, )
    @inner      = create(:option)
    @outer      = create(:option)
    @position   = create(:position, {
      expires_on: '2026-02-20',
      inner:    @inner,
      outer:    @outer,
      put_call: 'PUT',
      strategy: @strategy,
    })

    fake_quote_bundles = [ '2026-02-20_GME_PUT', '2026-02-27_GME_PUT' ]
    fake_quote_bundles.each do |bundle|
      bs = bundle.split('_')
      fake_quotes = JSON.parse(File.read("data/schwab/#{bundle}.json")).map &:deep_symbolize_keys
      allow( Tda::Option ).to receive( :get_quotes ).with({ contractType: bs[2], ticker: bs[1], expirationDate: bs[0] }).and_return(fake_quotes)
    end
    fake_quote_bundles = [
      '2026-02-20_META_810_CALL',
      '2026-02-27_GME_16_PUT',
      '2026-02-27_GME_21_PUT',
      '2026-02-27_META_790_CALL',
      '2026-02-27_META_810_CALL',
      '2026-02-27_META_810_PUT',
    ];
    fake_quote_bundles.each do |bundle|
      bs = bundle.split('_')
      fake_quotes = JSON.parse(File.read("data/schwab/#{bundle}.json")).map &:deep_symbolize_keys
      allow( Tda::Option ).to receive( :get_quotes ).with({ strike: bs[2].to_f, contractType: bs[3], ticker: bs[1], expirationDate: bs[0] }).and_return(fake_quotes)
    end

  end

  ##
  ## today is 2026-02-16
  ##
  describe '#new' do
    it 'renders' do
      @stock_gme = create(:stock, last: 23.57, ticker: 'GME' )
      @strategy  = create(:strategy_long_credit_put_spread, {
        next_buffer_above_water: 1.00,
        next_inner_delta: 0.2,
        next_inner_strike: 21,
        next_spread_amount: 5.0,
        stock: @stock_gme,
      })
      get :new, params: { position: {
        expires_on: '2026-02-20',
        purse_id: @purse.id,
        strategy_id: @strategy.id,
      } }
      response.code.should eql '200'
    end
  end

  describe '#prepare' do
    it 'prepare_long_credit_put_spread' do
      get :prepare, params: { id: @position.id }
      response.code.should eql '200'
    end
  end

  describe '#update' do
    it 'updates inner begin_price, begin_delta' do
      pos = create( :position, {
        inner: create(:option, begin_price: 0.99, begin_delta: 0.2),
        outer: create(:option),
        put_call: 'PUT',
      })
      post :update, params: { id: pos.id, position: { expires_on: pos.expires_on },
        inner: { begin_price: 2.01, begin_delta: 0.33 },
        outer: { begin_price: pos.outer.begin_price } }
      pos.reload
      pos.inner.begin_price.should eql 2.01
      pos.inner.begin_delta.should eql 0.33
    end
  end

end
