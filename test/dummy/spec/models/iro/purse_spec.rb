
RSpec.describe Iro::Purse do

  before do
    destroy_every(
      Iro::Option,
      Iro::Purse,
      Iro::Position,
      Iro::Stock,
      Iro::Strategy,
    )
    @stock    = create(:stock, last: 100 )
    @strategy = create(:strategy,
      kind: Iro::Strategy::KIND_LONG_DEBIT_CALL_SPREAD,
      stock: @stock,
    )
  end

  it '#wt_avg_begin_inner_d_long' do
    @purse = create(:purse, stock: @stock)
    outer_1 = Iro::Option.create({
      stock: @stock,
      expires_on: '2024-01-01',
      strike: 70,
      begin_price: 0.91,
      begin_delta: 0.85,
      put_call: 'CALL',
    })
    inner_1 = Iro::Option.create({
      stock: @stock,
      expires_on: '2024-01-01',
      strike: 80,
      begin_price: 1.11,
      begin_delta: 0.72,
      put_call: 'CALL',
    })
    pos_1 = Iro::Position.create({
      status: 'active',
      expires_on: '2024-01-01',
      quantity: 1,

      stock: @stock,
      strategy: @strategy,
      inner: inner_1,
      inner_strike: inner_1.strike,

      outer: outer_1,
      outer_strike: outer_1.strike,

      purse: @purse,
      long_or_short: Iro::Strategy::LONG,
    })

    outer_2 = Iro::Option.create({
      stock: @stock,
      expires_on: '2024-01-01',
      strike: 80,
      begin_price: 1.11,
      begin_delta: 0.75,
      put_call: 'CALL',
    })
    inner_2 = Iro::Option.create({
      stock: @stock,
      expires_on: '2024-01-01',
      strike: 90,
      begin_price: 1.51,
      begin_delta: 0.62,
      put_call: 'CALL',
    })
    pos_2 = Iro::Position.create({
      status: 'active',
      expires_on: '2024-01-01',
      quantity: 2,

      stock: @stock,
      strategy: @strategy,

      inner: inner_2,
      inner_strike: inner_2.strike,

      outer: outer_2,
      outer_strike: outer_2.strike,

      purse: @purse,
      long_or_short: Iro::Strategy::LONG,
    })
    expected = 0.6533
    # puts! expected, 'expected'
    ( @purse.delta_wt_avg( :begin, :long, :inner ) - expected ).should < EPSILON
    ## expected = 0.9198
    @purse.delta_to_plot_p( :begin, :long, :inner ).should eql "82%"
  end

end
