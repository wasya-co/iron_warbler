
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
    @purse      = create(:purse, )

    @stock_meta = create(:stock, ticker: 'META', last: 400, options_price_increment: 5.0 )
    @strategy   = create(:strategy_long_credit_put_spread, stock: @stock_meta)
    @inner      = create(:option)
    @outer      = create(:option)
    @position   = create(:position, {
      expires_on: '2026-02-20',
      inner:    @inner, inner_strike: @inner.strike,
      outer:    @outer, outer_strike: @outer.strike,
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

  describe '#create' do

    it 'long_credit_put_spread' do
      n = Iro::Position.all.length
      strategy = create(:strategy, kind: Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD )
      allow_any_instance_of( Iro::Option ).to receive( :sync ) ## .with().and_return(fake_quotes)
      post :create, params: {
        inner: {
          strike: 500.0,
          begin_price: 1.0,
          begin_delta: 0.5,
        },
        outer: {
          strike: 500.0,
          begin_price: 1.0,
          begin_delta: 0.5,
        },
        position: {
          expires_on: '2026-02-27',
          inner_strike: 810.0,
          outer_strike: 500.0,
          purse_id: @purse.id,
          quantity: 1,
          status: 'active',
          stock_id: @stock_meta.id,
          strategy_id: strategy.id.to_s,
        },
      }
      Iro::Position.all.length.should eql( n + 1 )
    end
  end

  ## 2026-02-16
  describe '#new' do
    before do
      @stock_gme = create(:stock, last: 23.57, ticker: 'GME' )
    end

    it 'strategy long_credit_put_spread' do
      purse = create(:purse)
      strategy  = create(:strategy_long_credit_put_spread, {
        next_usd_above_mark: 1.00,
        next_inner_delta: 0.2,
        next_inner_strike: 21,
        next_spread_amount: 5.0,
        stock: @stock_gme,
      })
      get :new, params: { position: {
        expires_on: '2026-02-20',
        purse_id: purse.id,
        strategy_id: strategy.id,
      } }
      response.code.should eql '200'
      assert_select '.positions--form-spread'
    end

  end

  describe '#prepare' do
    it 'prepare_long_credit_put_spread' do
      fake_quotes = [
        { strikePrice: 775, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 780, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 785, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 790, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 795, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 800, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 805, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 810, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 815, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 820, delta: 0.1, bid: 0.1, ask: 0.2 },
        { strikePrice: 825, delta: 0.1, bid: 0.1, ask: 0.2 },
      ]
      allow( Tda::Option ).to receive( :get_quotes ).with({ contractType: 'PUT', ticker: @position.stock.ticker, expirationDate: '2026-02-27' }).and_return(fake_quotes)

      get :prepare, params: { id: @position.id }
      response.code.should eql '200'
    end
  end

  describe '#update' do
    it 'updates inner begin_price, begin_delta' do
      pos = create( :position, {
        inner: create(:option, begin_price: 0.99, begin_delta: 0.2), inner_strike: 800.0,
        outer: create(:option), outer_strike: 800.0,
        put_call: 'PUT',
      })
      post :update, params: { id: pos.id, position: { expires_on: pos.expires_on },
        inner: { begin_price: 2.01, begin_delta: 0.33 }, inner_strike: 800.0,
        outer: { begin_price: pos.outer.begin_price, end_price: 0.56 }, outer_strike: 800.0,
      };
      pos.reload
      pos.inner.begin_price.should eql 2.01
      pos.inner.begin_delta.should eql 0.33
      pos.outer.end_price.should eql 0.56
    end

  end

end
