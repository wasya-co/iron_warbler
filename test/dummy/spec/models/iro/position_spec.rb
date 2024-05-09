
RSpec.describe Iro::Position do

  before do
    destroy_every(
      Iro::Position,
      Iro::Stock,
      Iro::Strategy,
    )
    @stock    = create(:stock, last: 11.5 )
    @strategy = create(:strategy,
      kind: Iro::Strategy::KIND_LONG_DEBIT_CALL_SPREAD,
      stock: @stock,
    )
  end

  it '#breakeven for long_debit_call_spread' do
    @pos = Iro::Position.create({
      status: 'active',
      expires_on: '2024-01-01',
      quantity: 1,

      begin_outer_price: 0.8,
      begin_inner_price: 0.6,
      stock: @stock,
      strategy: @strategy,
      outer_strike: 9,
      inner_strike: 10,
    })
    # @pos.breakeven.should eql( @pos.inner_strike - @pos.begin_outer_price + @pos.begin_inner_price )
    ( @pos.breakeven - 9.8 ).should < EPSILON
  end

  it '#net_amount' do
    @pos = Iro::Position.create({
      status: 'active',
      expires_on: '2024-01-01',
      quantity: 2,
      stock: @stock,
      strategy: create(:strategy,
        kind: Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD,
        stock: @stock ),

      inner: create( :option, begin_price: 0.6, end_price: 0.99 ),
      outer: create( :option, begin_price: 0.8, end_price: 0.7 ),
    })
    expected = 0.6 - 0.99 - 0.8 + 0.7
    ( @pos.net_amount - expected ).should < EPSILON
  end

end
