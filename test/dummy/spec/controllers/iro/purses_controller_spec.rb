
RSpec.describe Iro::PursesController do
  render_views
  routes { Iro::Engine.routes }

  before do
    setup_users
    destroy_every(
      Iro::Option,
      Iro::Position, Iro::Purse,
      Iro::Stock,    Iro::Strategy,
    );
    @purse = create(:purse)
    @stock_meta = create(:stock, ticker: 'META', options_price_increment: 5.0 )
  end

  context '#show' do
    it 'table for long_credit_put_spread' do
      strategy   = create(:strategy_long_credit_put_spread, stock: @stock_meta )
      inner      = create(:option, begin_price: 10 )
      outer      = create(:option, begin_price: 20 )
      position   = create(:position, {
        expires_on: '2024-04-19',
        inner: inner, inner_strike: inner.strike,
        outer: outer, outer_strike: outer.strike,
        put_call: 'PUT',
        purse: @purse,
        strategy: strategy,
      })

      ## quotes_h[pos.expires_on.to_s][pos.put_call][pos.inner.strike][:price]
      fake_quotes = {
        '2024-04-19' => {
          'PUT' => {
            800.0 => {
              price: 0.1,
              delta: 0.1,
            },
          },
        },
      }
      allow( Tda::Option ).to receive( :get_quotes_h
        # ).with({ contractType: 'PUT', ticker: position.stock.ticker, expirationDate: '2026-02-27' }
        ).and_return(fake_quotes)
      get :show, params: { id: @purse.id }
      response.code.should eql '200'
    end

  end

end

